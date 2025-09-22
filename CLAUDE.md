# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### NX Monorepo Commands
- **Build all services**: `cd services && nx run-many -t build`
- **Run specific service**: `cd services && nx run <project-name>:serve` (e.g., `nx run api-reports:serve`)
- **Test all**: `cd services && nx run-many -t test`
- **Test single project**: `cd services && nx run <project-name>:test`
- **Integration tests**: `cd services && nx run <project-name>:test-integration`
- **Lint**: `cd services && nx run-many -t lint`
- **Format code**: `cd services && npx nx format:write`

**IMPORTANT**: Always run `npx nx format:write` after implementing new features to ensure consistent code formatting and avoid CI failures.

### Key Build Commands (from services/package.json)
- **API Reports**: `npm run api-reports:build`
- **API Upload**: `npm run api-upload:build` 
- **Workers Ingest**: `npm run workers-ingest:build`
- **Workers Processing**: `npm run workers-processing:build`
- **Lambda Functions**: `npm run lambda:package`

### Local Development
- **Start full stack**: `docker compose up --build`
- **Start specific services**: `docker compose --profile api up` or `docker compose --profile workers up`
- **Database migrations**: Handled automatically by Docker compose
- **ClickHouse CLI**: Available at `http://localhost:8124/play` (default:default)

### Database Operations
- **ClickHouse migrations**: `cd services/clickhouse && ./migrate.sh`
- **Generate test fixtures**: `cd services && npm run generate-fixture`

## Architecture Overview

### Core Services Architecture
This is a **multi-tenant e-commerce analytics platform** built as an NX monorepo that ingests data from commerce platforms (Shopify, Amazon, Klaviyo, etc.) and provides predictive analytics.

**Main Applications:**
- **api-reports** (port 3000): NestJS API serving metrics/reports to Lifetimely
- **api-upload** (port 3003): File upload service for CSV imports
- **workers-ingest** (port 3001): BullMQ worker pulling data from 3rd-party APIs to S3
- **workers-processing** (port 3002): BullMQ worker processing raw data into analytics tables
- **lambda functions**: AWS Lambda for S3→ClickHouse data processing and webhook handling
- **predictive services**: Python ML models for LTV prediction using Random Forest and Logistic Regression

### Data Flow Architecture
1. **Ingestion**: API/Webhook → S3 (raw JSON) → Lambda → ClickHouse (structured)
2. **Processing**: ClickHouse raw tables → Materialized Views → Curated multi-platform tables
3. **Reporting**: Client → Reports API → ClickHouse analytics queries → Response

### Database Schema Patterns
- **Raw Tables**: Store exact JSON API responses (e.g., `shopify_raw_orders`)
- **Materialized Views**: Transform JSON to structured tables (e.g., `shopify_orders_v6`)
- **Curated Tables**: Multi-platform normalized tables (e.g., `curated_orders_v2`)
- **Versioned Schema**: Tables use version suffixes (v1, v2, v6) for safe schema evolution
- **Monthly Partitioning**: All tables partitioned by `toYYYYMM(processed_at)` for performance

### Key Libraries (services/libs/)
- **ingest/**: Integration job classes, API endpoints, credential management
- **processing/**: BullMQ consumers/producers, reprocessing workflows
- **reports/**: Report modules (attribution, benchmarks, customer behavior, LTV)
- **utils/**: Shared utilities (ClickHouse client, auth, config, sanitization)

## Development Conventions

### File Organization
- **Apps**: Deployable services in `services/apps/`
- **Libs**: Reusable business logic in `services/libs/`
- **Migrations**: ClickHouse schema in `services/clickhouse/migrations/`
- **Infrastructure**: Terraform modules in `infra/modules/`

### Testing Patterns
- **Unit tests**: `*.spec.ts` files alongside source code
- **Integration tests**: `*.integration.spec.ts` using real database fixtures
- **E2E tests**: `apps/api/reports-e2e/` for API endpoint testing
- **Test fixtures**: Generated ClickHouse data via `generate-fixture` command

### Code Style
- **NestJS**: Standard decorators and dependency injection patterns
- **ClickHouse**: Use parameterized queries, avoid SQL injection
- **Multi-tenancy**: Always filter by `shop` domain in queries
- **Error Handling**: Use structured logging with Pino, include context
- **Authentication**: JWT tokens + shared secrets for API access
- **Object Parameters**: Use object parameters instead of positional arguments when:
  - Method has 4+ parameters
  - Any parameter is a boolean (avoids boolean trap anti-pattern)
  - Parameters have default values beyond the first few
  - Example: `getData({ shopDomain, includeDeleted: false })` instead of `getData(shopDomain, false)`

### Integration Development
- **New Integration**: Follow template in `docs/integrations/template.md`
- **API Patterns**: Support both webhook (real-time) and polling (batch) patterns
- **Schema Evolution**: Always create new table versions, never alter existing
- **Data Validation**: Strong typing with class-transformer/class-validator

## Infrastructure Notes

### Local Development Stack
- **ClickHouse**: Analytics database on port 8123
- **PostgreSQL**: Metadata/job tracking on port 5432
- **Redis**: Two instances for ingest/processing job queues
- **MinIO**: S3-compatible storage on port 9003
- **Grafana**: Observability at http://localhost:3000/grafana

### AWS Production Environment
- **ECS**: Containerized services with auto-scaling
- **Lambda**: Event-driven processing functions
- **ClickHouse Cloud**: Managed analytics database
- **S3**: Raw data storage with lifecycle policies
- **Terraform**: Infrastructure as Code in `infra/` directory

### Monitoring & Observability
- **OpenTelemetry**: Distributed tracing enabled
- **Grafana Cloud**: Production observability at https://amplifetimely.grafana.net/
- **BullMQ Dashboard**: Job queue monitoring at `/api/bullmq/queue/ingest`
- **Swagger**: API documentation at `/specification`

## Common Development Workflows

### Adding New Report Endpoint
1. Create report module in `libs/reports/src/lib/`
2. Add ClickHouse query logic with proper filtering
3. Implement controller in `apps/api/reports/src/app/`
4. Add integration tests with fixtures
5. Update Swagger documentation

### Adding New Integration
1. Follow `docs/integrations/template.md`
2. Create job class in `libs/ingest/src/lib/jobs/`
3. Add API credentials handling
4. Create raw table migration in `services/clickhouse/migrations/`
5. Add materialized view for structured data
6. Test with local credentials driver

### Schema Migration Process
1. Create new migration file: `000XXX_description.sql`
2. Use versioned table names (e.g., `orders_v7`)
3. Create materialized view to populate new table
4. Update application code to use new table
5. Test with sample data before production deployment

### Performance Optimization
- **ClickHouse**: Use `PREWHERE` for partition pruning, avoid `SELECT *`
- **Indexes**: Sparse indexes on filter columns, avoid too many indexes
- **Partitioning**: Monthly partitions are pre-configured, leverage in queries
- **Materialized Views**: Pre-compute expensive aggregations
- **Job Queues**: Use priorities and delays to manage processing load