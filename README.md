# micro-services-infra001-aws

AWS port of the original Azure Terraform setup (`resource_group` + `acr` + `aks`).

## Module mapping

| Azure (original)     | AWS (this repo)      | Notes |
|-----------------------|-----------------------|-------|
| `modules/resource_group` | *(removed)*         | Azure resource groups are a pure logical container with no AWS equivalent. |
| *(implicit, AKS handles it)* | `modules/vpc` (new) | AWS EKS requires real network infra AKS gets for free: VPC, public/private subnets, IGW, NAT Gateway. |
| `modules/acr`          | `modules/ecr`         | Same for_each-over-map shape. ACR's `admin_enabled` (static credentials) has no direct ECR equivalent -- ECR is IAM-authenticated only, which is the more secure AWS-native pattern anyway. |
| `modules/aks`          | `modules/eks`          | AWS requires explicit IAM roles for both the control plane and the node group (`aws_iam_role` + policy attachments) -- AKS's `identity { type = "SystemAssigned" }` block does this invisibly. |

## Security fix carried over from the original

The original `environments/dev/providers.tf` had a real Azure `subscription_id`
hardcoded and committed in plaintext. The AWS `providers.tf` here deliberately
has **no hardcoded account ID or credentials** -- authentication comes from
whatever's already configured (env vars, `~/.aws/credentials` profile, or an
assumed IAM role via GitHub OIDC in CI, which is what `.github/workflows/terraform.yml`
uses).

## What I could NOT verify in this environment

I don't have Terraform, the AWS provider, or AWS credentials available in the
sandbox this was generated in, so **I was only able to sanity-check brace/paren/
bracket balance in every `.tf` file -- not real `terraform fmt`/`validate`/`plan`.**
You must run the following yourself before trusting this, in order:

```bash
cd environments/dev
terraform fmt -recursive ..          # auto-fixes formatting across modules/ and environments/
terraform init                       # downloads the AWS provider
terraform validate                   # checks HCL syntax + internal consistency
terraform plan                       # requires real AWS credentials -- review carefully before apply
terraform apply                      # only after reviewing the plan output
```

Things worth double-checking specifically, since I wrote this without being
able to execute any of it:

- The `aws_eks_node_group.scaling_config` block (desired/min/max all set equal
  to `node_count`) -- fine for a fixed-size dev node pool, but you'll likely
  want `min_size < max_size` for any real autoscaling.
- `instance_type = "t3.medium"` as the port of `Standard_B2s` -- roughly
  comparable burstable-CPU sizing, not an exact spec match; adjust to your
  actual workload needs.
- ECR repository name `"micro-dev"` -- renamed from the original
  `"acrmicrodev556677"` because ECR repository names must be lowercase and
  don't need to be globally unique the way ACR names do (ACR names are
  globally unique across all of Azure; ECR names only need to be unique
  within your AWS account + region). Rename freely.
- The single NAT Gateway in `modules/vpc` is cost-optimized for a dev
  environment (~$32/mo + data processing) but is a single point of failure
  across AZs. For prod, that's one NAT Gateway per AZ instead.

## Pushing to GitHub

I don't have your GitHub credentials, so I can't push this for you. From this
extracted folder:

```bash
git init
git add -A
git commit -m "Port infra from Azure (AKS/ACR) to AWS (EKS/ECR)"
git branch -M main
git remote add origin <your-new-or-existing-repo-url>
git push -u origin main
```

If you're pushing to the *same* repo as the original Azure code, consider a
separate branch (e.g. `aws-migration`) rather than overwriting `main` directly,
so you can diff and review before merging.
