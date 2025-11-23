/**
 * Terraform Infrastructure Container - Main Worker Entry Point
 *
 * A portable, self-contained Cloudflare Worker for managing multi-cloud
 * infrastructure via Terraform. No Docker required!
 *
 * @author joe@theholetruth.org
 * @organization HOLE Foundation
 */

import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { prettyJSON } from 'hono/pretty-json';

// Type definitions for Cloudflare Worker bindings
type Bindings = {
	// Environment variables
	ENVIRONMENT: string;
	PROJECT_NAME: string;
	MANAGED_BY: string;

	// Secrets (set via wrangler secret put)
	CLOUDFLARE_API_TOKEN?: string;
	AUTH0_CLIENT_ID?: string;
	AUTH0_CLIENT_SECRET?: string;
	AUTH0_DOMAIN?: string;

	// KV Namespaces (when configured)
	TERRAFORM_STATE?: KVNamespace;
	TERRAFORM_CONFIG?: KVNamespace;

	// R2 Buckets (when configured)
	TERRAFORM_ARTIFACTS?: R2Bucket;

	// D1 Databases (when configured)
	DEPLOYMENT_DB?: D1Database;
};

// Initialize Hono app with type-safe bindings
const app = new Hono<{ Bindings: Bindings }>();

// Middleware
app.use('*', logger());
app.use('*', prettyJSON());
app.use('*', cors({
	origin: ['https://theholetruth.org', 'https://theholefoundation.org', 'http://localhost:*'],
	allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
	allowHeaders: ['Content-Type', 'Authorization'],
	credentials: true,
}));

// ============================================================================
// ROUTES
// ============================================================================

/**
 * Health check endpoint
 */
app.get('/', (c) => {
	return c.json({
		status: 'healthy',
		service: 'terraform-infrastructure-container',
		environment: c.env.ENVIRONMENT || 'unknown',
		project: c.env.PROJECT_NAME || 'HOLE Foundation Infrastructure',
		version: '1.0.0',
		runtime: 'Cloudflare Workers (Workerd)',
		message: 'Portable Terraform infrastructure management - No Docker required!',
	});
});

/**
 * Get project information and configuration
 */
app.get('/api/info', (c) => {
	return c.json({
		project: {
			name: c.env.PROJECT_NAME || 'HOLE Foundation Infrastructure',
			environment: c.env.ENVIRONMENT || 'development',
			managedBy: c.env.MANAGED_BY || 'terraform',
		},
		infrastructure: {
			providers: ['Azure', 'Cloudflare', 'Auth0'],
			planned: ['AWS', 'Google Cloud', 'GitHub'],
		},
		features: {
			dockerFree: true,
			portable: true,
			edgeDeployment: true,
			githubSync: true,
		},
		resources: {
			kvNamespaces: !!c.env.TERRAFORM_STATE || !!c.env.TERRAFORM_CONFIG,
			r2Buckets: !!c.env.TERRAFORM_ARTIFACTS,
			d1Database: !!c.env.DEPLOYMENT_DB,
		},
	});
});

/**
 * Get Terraform state information (placeholder)
 * TODO: Implement actual state management with KV
 */
app.get('/api/terraform/state', async (c) => {
	if (!c.env.TERRAFORM_STATE) {
		return c.json({
			error: 'TERRAFORM_STATE KV namespace not configured',
			message: 'Add KV namespace binding in wrangler.toml',
		}, 503);
	}

	// TODO: Implement state retrieval from KV
	return c.json({
		message: 'Terraform state management endpoint',
		status: 'not_implemented',
		todo: 'Implement KV-based state storage',
	});
});

/**
 * List managed infrastructure resources (placeholder)
 */
app.get('/api/terraform/resources', async (c) => {
	// TODO: Query from D1 database or KV
	return c.json({
		message: 'Infrastructure resources endpoint',
		resources: {
			azure: {
				subscriptions: 4,
				resourceGroups: 'managed_via_terraform',
			},
			cloudflare: {
				zones: ['theholetruth.org', 'theholefoundation.org'],
				workers: 'multiple',
				r2Buckets: 'managed',
				kvNamespaces: 'managed',
			},
			auth0: {
				domain: 'dev-4fszoklachwdh46m.us.auth0.com',
				customDomain: 'auth.theholetruth.org',
				applications: 2,
			},
		},
		status: 'not_implemented',
		todo: 'Implement resource inventory from D1',
	});
});

/**
 * Trigger Terraform plan (placeholder)
 * TODO: Implement with Durable Objects for long-running operations
 */
app.post('/api/terraform/plan', async (c) => {
	return c.json({
		message: 'Terraform plan endpoint',
		status: 'not_implemented',
		todo: 'Implement with Durable Objects for execution state',
	}, 501);
});

/**
 * Trigger Terraform apply (placeholder)
 * TODO: Implement with proper authentication and authorization
 */
app.post('/api/terraform/apply', async (c) => {
	return c.json({
		message: 'Terraform apply endpoint',
		status: 'not_implemented',
		todo: 'Implement with Auth0 authentication and approval workflow',
		security: 'Requires multi-factor authentication and audit logging',
	}, 501);
});

/**
 * Get deployment history (placeholder)
 */
app.get('/api/deployments', async (c) => {
	if (!c.env.DEPLOYMENT_DB) {
		return c.json({
			error: 'DEPLOYMENT_DB D1 database not configured',
			message: 'Add D1 binding in wrangler.toml',
		}, 503);
	}

	// TODO: Query deployment history from D1
	return c.json({
		message: 'Deployment history endpoint',
		status: 'not_implemented',
		todo: 'Query D1 database for deployment records',
	});
});

/**
 * Upload artifact to R2 (placeholder)
 */
app.post('/api/artifacts/upload', async (c) => {
	if (!c.env.TERRAFORM_ARTIFACTS) {
		return c.json({
			error: 'TERRAFORM_ARTIFACTS R2 bucket not configured',
			message: 'Add R2 binding in wrangler.toml',
		}, 503);
	}

	// TODO: Implement R2 upload with multipart support
	return c.json({
		message: 'Artifact upload endpoint',
		status: 'not_implemented',
		todo: 'Implement R2 multipart upload for Terraform plans and artifacts',
	}, 501);
});

/**
 * 404 handler
 */
app.notFound((c) => {
	return c.json({
		error: 'Not Found',
		message: 'The requested endpoint does not exist',
		availableEndpoints: [
			'GET /',
			'GET /api/info',
			'GET /api/terraform/state',
			'GET /api/terraform/resources',
			'POST /api/terraform/plan',
			'POST /api/terraform/apply',
			'GET /api/deployments',
			'POST /api/artifacts/upload',
		],
	}, 404);
});

/**
 * Error handler
 */
app.onError((err, c) => {
	console.error('Worker error:', err);
	return c.json({
		error: 'Internal Server Error',
		message: err.message,
		environment: c.env.ENVIRONMENT,
	}, 500);
});

// Export the Hono app as the default Worker handler
export default app;
