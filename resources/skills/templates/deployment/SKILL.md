# Deployment Skill

<!-- SKILL TEMPLATE — Sections marked [FILL] should be populated
     with project-specific details by the ralph loop during interview
     or build mode. -->

## Overview
Deployment covers how the application is built, shipped, and run in production.
This skill covers the target platform, CI/CD pipeline, environment management,
and operational concerns.
[FILL: Deployment strategy for THIS project — platform, frequency, approach]

## Target Platform
- Hosting: [FILL: Vercel / AWS / GCP / Fly.io / Railway / self-hosted]
- Runtime: [FILL: Node.js / Edge / Serverless / Container]
- CDN: [FILL: Vercel Edge Network / CloudFront / Cloudflare / none]
- Region: [FILL: Primary region, multi-region if applicable]

## Build Process
- Build command: [FILL: npm run build / custom build script]
- Output: [FILL: Static export / Node server / Docker image]
- Build time: [FILL: Approximate build duration]
- [FILL: Special build steps — codegen, asset optimization, etc.]

## CI/CD Pipeline
- Platform: [FILL: GitHub Actions / GitLab CI / CircleCI / etc.]
- Trigger: [FILL: On push to main, PR merge, manual dispatch]
- Pipeline steps: [FILL: Lint, test, build, deploy — in order]
- Branch strategy: [FILL: main -> production, develop -> staging, PR -> preview]

## Environments
- Production: [FILL: URL, how deploys reach prod]
- Staging: [FILL: URL, how staging is updated]
- Preview: [FILL: PR preview deployments — automatic?]
- Local: [FILL: How to run a production-like build locally]

## Environment Variables
- Management: [FILL: Vercel dashboard / AWS SSM / .env files / Doppler]
- Required vars: [FILL: Key env vars needed for deployment]
- Secrets rotation: [FILL: How secrets are rotated]
- [FILL: Env var naming conventions — NEXT_PUBLIC_ prefix rules, etc.]

## Infrastructure
- Database: [FILL: Managed DB service, connection in production]
- Storage: [FILL: S3 / R2 / Supabase Storage — for uploads/assets]
- Email: [FILL: Resend / SendGrid / SES — transactional email]
- Monitoring: [FILL: Sentry / Datadog / Vercel Analytics]
- Logging: [FILL: Where logs go, log aggregation service]

## Project Conventions
[FILL: Project-specific deployment patterns and conventions]
- Release process: [FILL: Versioning, changelogs, release tags]
- Rollback procedure: [FILL: How to roll back a bad deploy]
- Feature flags: [FILL: LaunchDarkly / Vercel Edge Config / custom]

## Key Constraints
- [FILL: Uptime requirements / SLAs]
- [FILL: Cost considerations — serverless limits, bandwidth]
- [FILL: Compliance — data residency, SOC2, etc.]

## Where to Look
- CI config: [FILL: Path to .github/workflows/ or equivalent]
- Docker: [FILL: Path to Dockerfile, docker-compose.yml]
- Infra-as-code: [FILL: Path to Terraform / Pulumi / CDK files]
- Deploy scripts: [FILL: Path to deployment scripts]
- Environment config: [FILL: Path to .env.example or env schema]
- Docs: [FILL: Link to hosting platform docs]

## Common Pitfalls
- [FILL: Things discovered during development that weren't obvious]
- [FILL: Build failures encountered and their resolutions]
- [FILL: Environment variable mismatches between local and production]
