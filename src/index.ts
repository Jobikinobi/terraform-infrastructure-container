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
import * as ServicesAPI from './services-api';

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
		service: 'HOLE Substrate',
		tagline: 'The foundational infrastructure layer for HOLE Foundation',
		environment: c.env.ENVIRONMENT || 'unknown',
		version: '1.0.0',
		runtime: 'Cloudflare Workers (V8)',
		message: 'Infrastructure-as-a-Service for all HOLE Foundation projects',
		url: 'https://substrate.theholefoundation.org',
		documentation: 'https://github.com/Jobikinobi/terraform-infrastructure-container'
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
 * VPC Test Endpoint
 * Tests private Azure resource access via VPC
 */
app.get('/api/vpc/test', async (c) => {
	if (!c.env.AZURE_VPC) {
		return c.json({
			error: 'VPC not configured',
			message: 'AZURE_VPC binding not available. VPC service may not be deployed.',
			status: 'not_configured',
		}, 503);
	}

	try {
		// Test VPC connection
		const result = await c.env.AZURE_VPC.fetch('https://azure.internal/health');

		return c.json({
			message: 'VPC connection successful',
			vpc_service: 'azure-private-resources',
			status: 'connected',
			response_status: result.status,
		});
	} catch (error) {
		return c.json({
			error: 'VPC connection failed',
			message: error.message,
			status: 'tunnel_not_running',
			note: 'Tunnel connector needs to be running in Azure VNet',
		}, 503);
	}
});

/**
 * ========================================
 * Infrastructure-as-a-Service API Endpoints
 * ========================================
 */

/**
 * Service Discovery
 * Lists all available infrastructure services
 */
app.get('/api/services', ServicesAPI.getServices);

/**
 * Auth0 Configuration Service
 */
app.get('/api/auth0/config/:project', ServicesAPI.getAuth0Config);
app.get('/api/auth0/clients', ServicesAPI.listAuth0Clients);

/**
 * Cloudflare Resources Service
 */
app.get('/api/cloudflare/resources/:project', ServicesAPI.getCloudflareResources);

/**
 * DNS Service
 */
app.get('/api/dns/zone/:domain', ServicesAPI.getDNSZone);

/**
 * Project Configuration
 */
app.get('/api/projects/:project', ServicesAPI.getProjectConfig);
app.get('/api/projects', ServicesAPI.listProjects);

/**
 * ========================================
 * GitHub Integration
 * ========================================
 */

/**
 * GitHub Webhook Handler
 * Processes events from GitHub (push, issues, PRs, etc.)
 */
app.post('/api/github/webhook', async (c) => {
	const eventType = c.req.header('X-GitHub-Event');
	const deliveryId = c.req.header('X-GitHub-Delivery');

	if (!eventType) {
		return c.json({ error: 'Missing X-GitHub-Event header' }, 400);
	}

	try {
		const payload = await c.req.json();

		// Ensure repository exists in D1 (for foreign key)
		if (c.env.DEPLOYMENT_DB && payload.repository) {
			await c.env.DEPLOYMENT_DB.prepare(
				'INSERT OR IGNORE INTO github_repositories (repo_id, repo_name, repo_full_name, description, visibility, created_at) VALUES (?, ?, ?, ?, ?, ?)'
			).bind(
				payload.repository.id,
				payload.repository.name,
				payload.repository.full_name,
				payload.repository.description || '',
				payload.repository.private ? 'private' : 'public',
				new Date().toISOString()
			).run();
		}

		// Log webhook event to D1
		if (c.env.DEPLOYMENT_DB) {
			await c.env.DEPLOYMENT_DB.prepare(
				'INSERT INTO webhook_events (event_id, event_type, source, repo_full_name, payload, received_at) VALUES (?, ?, ?, ?, ?, ?)'
			).bind(
				deliveryId || `${Date.now()}`,
				eventType,
				'github',
				payload.repository?.full_name || null,
				JSON.stringify(payload),
				new Date().toISOString()
			).run();
		}

		// Handle specific event types
		switch (eventType) {
			case 'push':
				await handlePushEvent(c, payload);
				break;
			case 'issues':
				await handleIssueEvent(c, payload);
				break;
			case 'pull_request':
				await handlePullRequestEvent(c, payload);
				break;
			case 'ping':
				return c.json({ message: 'Webhook configured successfully!', pong: true });
			default:
				console.log(`Received ${eventType} event (not yet handled)`);
		}

		return c.json({
			received: true,
			eventType,
			deliveryId,
			repository: payload.repository?.full_name
		});

	} catch (error) {
		console.error('Webhook error:', error);
		return c.json({ error: 'Webhook processing failed', message: error.message }, 500);
	}
});

/**
 * Handle push events (commits pushed to repository)
 */
async function handlePushEvent(c: any, payload: any) {
	if (!c.env.DEPLOYMENT_DB) return;

	const commit = payload.head_commit;
	if (!commit) return;

	// Log git event
	await c.env.DEPLOYMENT_DB.prepare(
		'INSERT INTO git_events (event_id, event_type, repo_full_name, branch, commit_sha, commit_message, author, author_email, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
	).bind(
		commit.id,
		'push',
		payload.repository.full_name,
		payload.ref.replace('refs/heads/', ''),
		commit.id,
		commit.message,
		commit.author.name,
		commit.author.email,
		new Date().toISOString()
	).run();

	console.log(`Push event logged: ${commit.message} by ${commit.author.name}`);

	// TODO: Trigger deployment if push to main
	if (payload.ref === 'refs/heads/main') {
		console.log('Push to main detected - deployment trigger pending implementation');
	}
}

/**
 * Handle issue events (issues opened, closed, etc.)
 */
async function handleIssueEvent(c: any, payload: any) {
	if (!c.env.DEPLOYMENT_DB) return;

	const issue = payload.issue;
	const action = payload.action;

	if (action === 'opened') {
		// Store new task
		await c.env.DEPLOYMENT_DB.prepare(
			'INSERT INTO project_tasks (task_id, repo_full_name, title, body, state, assignee, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)'
		).bind(
			issue.number,
			payload.repository.full_name,
			issue.title,
			issue.body || '',
			issue.state,
			issue.assignee?.login || null,
			new Date().toISOString()
		).run();

		// Store labels
		if (issue.labels && issue.labels.length > 0) {
			for (const label of issue.labels) {
				await c.env.DEPLOYMENT_DB.prepare(
					'INSERT OR IGNORE INTO task_labels (task_id, label_name, label_color) VALUES (?, ?, ?)'
				).bind(issue.number, label.name, label.color).run();
			}
		}

		console.log(`New issue #${issue.number} logged: ${issue.title}`);
	} else if (action === 'closed') {
		// Update task status
		await c.env.DEPLOYMENT_DB.prepare(
			'UPDATE project_tasks SET state = ?, status = ?, closed_at = ?, updated_at = ? WHERE task_id = ? AND repo_full_name = ?'
		).bind('closed', 'done', new Date().toISOString(), new Date().toISOString(), issue.number, payload.repository.full_name).run();

		console.log(`Issue #${issue.number} closed`);
	}
}

/**
 * Handle pull request events
 */
async function handlePullRequestEvent(c: any, payload: any) {
	console.log(`PR ${payload.action}: ${payload.pull_request.title}`);
	// TODO: Implement PR tracking
}

/**
 * 404 handler
 */
app.notFound((c) => {
	return c.json({
		error: 'Not Found',
		message: 'The requested endpoint does not exist',
		availableEndpoints: {
			core: [
				'GET /',
				'GET /api/info',
			],
			services: [
				'GET /api/services',
				'GET /api/projects',
				'GET /api/projects/:project',
			],
			auth0: [
				'GET /api/auth0/config/:project',
				'GET /api/auth0/clients',
			],
			cloudflare: [
				'GET /api/cloudflare/resources/:project',
			],
			dns: [
				'GET /api/dns/zone/:domain',
			],
			terraform: [
				'GET /api/terraform/state',
				'GET /api/terraform/resources',
				'POST /api/terraform/plan',
				'POST /api/terraform/apply',
			],
			deployments: [
				'GET /api/deployments',
			],
			github: [
				'POST /api/github/webhook',
			],
			other: [
				'POST /api/artifacts/upload',
				'GET /api/vpc/test',
			]
		},
		documentation: 'https://github.com/Jobikinobi/terraform-infrastructure-container'
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
