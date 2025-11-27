/**
 * Infrastructure-as-a-Service API
 * Provides centralized infrastructure configuration for all HOLE Foundation projects
 */

import { Context } from 'hono';

/**
 * Service Discovery
 * Lists all available infrastructure services
 */
export async function getServices(c: Context) {
	return c.json({
		name: 'HOLE Foundation Infrastructure Service',
		version: '1.0.0',
		available_services: {
			auth: {
				provider: 'Auth0',
				description: 'Authentication and authorization',
				endpoints: {
					get_config: 'GET /api/auth0/config/:project',
					list_clients: 'GET /api/auth0/clients'
				}
			},
			database: {
				providers: ['Neon PostgreSQL', 'Azure SQL', 'AWS RDS'],
				description: 'Database provisioning and management',
				endpoints: {
					provision: 'POST /api/database/provision',
					get_connection: 'GET /api/database/connection/:project',
					list: 'GET /api/database/list'
				}
			},
			storage: {
				providers: ['Cloudflare R2', 'Azure Blob', 'AWS S3'],
				description: 'Object storage',
				endpoints: {
					provision: 'POST /api/storage/provision',
					get_config: 'GET /api/storage/config/:project'
				}
			},
			cloudflare: {
				provider: 'Cloudflare',
				description: 'Cloudflare resources (KV, R2, D1, Workers)',
				endpoints: {
					get_resources: 'GET /api/cloudflare/resources/:project'
				}
			},
			dns: {
				provider: 'Cloudflare',
				description: 'DNS management',
				endpoints: {
					get_zone: 'GET /api/dns/zone/:domain'
				}
			}
		},
		credits: {
			azure: '$3000+ available',
			aws: '$3000+ available',
			cloudflare: 'Sponsored (unlimited)'
		},
		documentation: 'https://github.com/Jobikinobi/terraform-infrastructure-container/blob/main/docs/INFRASTRUCTURE-AS-A-SERVICE.md'
	});
}

/**
 * Auth0 Configuration Service
 * Returns Auth0 client configuration for a project
 */
export async function getAuth0Config(c: Context) {
	const project = c.req.param('project');

	// Project to Auth0 client mapping
	const auth0Clients = {
		'theholetruth-org': {
			clientId: '96qWGonLhLBlMcQZzM8NXnJGJxV5WlEV',
			name: 'Theholetruth.org SPA',
			type: 'spa',
			description: 'Production SPA for theholetruth.org',
			callbacks: [
				'https://theholetruth.org/callback',
				'https://theholefoundation.org/callback',
				'https://auth.theholetruth.org/callback',
				'http://localhost:5173/callback'
			],
			allowedLogoutUrls: [
				'https://theholetruth.org',
				'https://theholefoundation.org',
				'https://auth.theholetruth.org',
				'http://localhost:5173'
			],
			allowedOrigins: [
				'https://theholetruth.org',
				'https://theholefoundation.org',
				'https://auth.theholetruth.org',
				'http://localhost:5173'
			]
		},
		'theholetruth-org-v2': {
			clientId: '96qWGonLhLBlMcQZzM8NXnJGJxV5WlEV',  // Same client for now
			name: 'Theholetruth.org V2',
			type: 'spa',
			description: 'Next.js version of theholetruth.org',
			callbacks: [
				'https://theholetruth.org/api/auth/callback',
				'http://localhost:3000/api/auth/callback'
			],
			allowedLogoutUrls: [
				'https://theholetruth.org',
				'http://localhost:3000'
			],
			allowedOrigins: [
				'https://theholetruth.org',
				'http://localhost:3000'
			]
		},
		'hole-foundation': {
			clientId: 'DqTnEfRYqURjzK8NngzEIvTI6em9b8nu',
			name: 'HOLE Foundation Web Apps',
			type: 'spa',
			description: 'Multi-environment SPA for HOLE Foundation',
			callbacks: [
				'https://theholetruth.org/callback',
				'https://theholefoundation.org/callback',
				'https://auth.theholetruth.org/callback',
				'http://localhost:8084/callback',
				'http://localhost:8085/callback',
				'http://localhost:5173/callback'
			],
			allowedLogoutUrls: [
				'https://theholetruth.org',
				'https://theholefoundation.org',
				'https://auth.theholetruth.org',
				'http://localhost:8084',
				'http://localhost:8085',
				'http://localhost:5173'
			],
			allowedOrigins: [
				'https://theholetruth.org',
				'https://theholefoundation.org',
				'https://auth.theholetruth.org',
				'http://localhost:8084',
				'http://localhost:8085',
				'http://localhost:5173'
			]
		}
	};

	const client = auth0Clients[project as keyof typeof auth0Clients];

	if (!client) {
		return c.json({
			error: 'Project not found',
			message: `No Auth0 configuration found for project: ${project}`,
			available_projects: Object.keys(auth0Clients)
		}, 404);
	}

	return c.json({
		project,
		auth0: {
			domain: 'dev-4fszoklachwdh46m.us.auth0.com',
			customDomain: 'auth.theholetruth.org',
			clientId: client.clientId,
			clientName: client.name,
			clientType: client.type,
			audience: 'https://api.theholetruth.org',
			scopes: ['openid', 'profile', 'email'],
			callbacks: client.callbacks,
			logoutUrls: client.allowedLogoutUrls,
			allowedOrigins: client.allowedOrigins,
			organizationUsage: 'allow',
			organizationRequireBehavior: 'pre_login_prompt'
		},
		usage: {
			nextjs: {
				example: `
// app/auth/[...auth0]/route.ts
import { handleAuth, handleLogin, handleCallback } from '@auth0/nextjs-auth0';

export const GET = handleAuth({
  login: handleLogin({
    authorizationParams: {
      audience: 'https://api.theholetruth.org',
      scope: 'openid profile email'
    }
  }),
  callback: handleCallback()
});
				`,
				envVars: {
					AUTH0_SECRET: 'Generate with: openssl rand -hex 32',
					AUTH0_BASE_URL: 'https://theholetruth.org',
					AUTH0_ISSUER_BASE_URL: `https://${client.customDomain || 'dev-4fszoklachwdh46m.us.auth0.com'}`,
					AUTH0_CLIENT_ID: client.clientId,
					AUTH0_CLIENT_SECRET: '*** Get from Cloudflare Worker secrets ***',
					AUTH0_AUDIENCE: 'https://api.theholetruth.org'
				}
			}
		}
	});
}

/**
 * List all Auth0 clients
 */
export async function listAuth0Clients(c: Context) {
	return c.json({
		clients: [
			{
				project: 'theholetruth-org',
				clientId: '96qWGonLhLBlMcQZzM8NXnJGJxV5WlEV',
				name: 'Theholetruth.org SPA',
				type: 'spa'
			},
			{
				project: 'hole-foundation',
				clientId: 'DqTnEfRYqURjzK8NngzEIvTI6em9b8nu',
				name: 'HOLE Foundation Web Apps',
				type: 'spa'
			},
			{
				project: 'terraform-management',
				clientId: 'F1JxAFyBNZBnXbmXz6Vh64VHF9KP97dn',
				name: 'Terraform-Management',
				type: 'm2m'
			}
		],
		domain: 'dev-4fszoklachwdh46m.us.auth0.com',
		customDomain: 'auth.theholetruth.org'
	});
}

/**
 * Cloudflare Resources Service
 * Returns Cloudflare resources (KV, R2, D1) for a project
 */
export async function getCloudflareResources(c: Context) {
	const project = c.req.param('project');

	// Project to Cloudflare resources mapping
	const cloudflareResources = {
		'theholetruth-org': {
			kvNamespaces: {
				'visitor-logs': 'Stores visitor tracking data',
				'cache': 'Application cache'
			},
			r2Buckets: {
				'holetruth-assets': 'Static assets and media'
			},
			d1Databases: {
				'holetruth-analytics': 'Analytics database'
			},
			workers: [
				{ name: 'web', url: 'https://theholetruth.org' },
				{ name: 'api', url: 'https://api.theholetruth.org' }
			],
			zones: ['theholetruth.org', 'theholefoundation.org']
		},
		'mipds': {
			kvNamespaces: {
				'mipds-cache': 'MIPDS application cache'
			},
			r2Buckets: {
				'mipds': 'MIPDS document storage',
				'mipds-backup': 'Backup storage'
			},
			workers: [
				{ name: 'mipds-api', url: 'https://mipds-api.joe-1a2.workers.dev' }
			]
		},
		'terraform-container': {
			kvNamespaces: {
				'TERRAFORM_STATE': '519f7ebc18ee461fb5983da094cb1184'
			},
			r2Buckets: {
				'terraform-artifacts': 'Terraform plans and artifacts'
			},
			d1Databases: {
				'terraform-deployments': '4526be36-55b2-4c8c-9012-f94e00ea1556'
			},
			workers: [
				{ name: 'terraform-infrastructure-container', url: 'https://terraform-infrastructure-container.joe-1a2.workers.dev' }
			]
		}
	};

	const resources = cloudflareResources[project as keyof typeof cloudflareResources];

	if (!resources) {
		return c.json({
			error: 'Project not found',
			message: `No Cloudflare resources configured for project: ${project}`,
			available_projects: Object.keys(cloudflareResources)
		}, 404);
	}

	return c.json({
		project,
		cloudflare: {
			account_id: '1a25a792e801e687b9fe4932030cf6a6',
			account_name: 'The HOLE Foundation',
			resources
		},
		usage: {
			bindingExample: `
// wrangler.toml
[[kv_namespaces]]
binding = "CACHE"
id = "namespace-id-here"

[[r2_buckets]]
binding = "ASSETS"
bucket_name = "bucket-name-here"
			`,
			workerExample: `
// In your Worker
const cachedData = await env.CACHE.get('key');
const file = await env.ASSETS.get('file.jpg');
			`
		}
	});
}

/**
 * DNS Zone Information
 */
export async function getDNSZone(c: Context) {
	const domain = c.req.param('domain');

	const zones = {
		'theholetruth.org': {
			zone_id: 'zone-id-theholetruth',
			nameservers: ['ns1.cloudflare.com', 'ns2.cloudflare.com'],
			status: 'active',
			plan: 'Free'
		},
		'theholefoundation.org': {
			zone_id: 'zone-id-holefoundation',
			nameservers: ['ns1.cloudflare.com', 'ns2.cloudflare.com'],
			status: 'active',
			plan: 'Free'
		}
	};

	const zone = zones[domain as keyof typeof zones];

	if (!zone) {
		return c.json({
			error: 'Domain not found',
			message: `DNS zone not managed for domain: ${domain}`,
			available_domains: Object.keys(zones)
		}, 404);
	}

	return c.json({
		domain,
		zone
	});
}

/**
 * Get complete project infrastructure configuration
 */
export async function getProjectConfig(c: Context) {
	const projectId = c.req.param('project');

	// Check if project exists in D1
	if (!c.env.DEPLOYMENT_DB) {
		return c.json({ error: 'Database not available' }, 503);
	}

	try {
		// Get project from D1
		const project = await c.env.DEPLOYMENT_DB.prepare(
			'SELECT * FROM projects WHERE project_id = ? OR github_repo LIKE ?'
		).bind(projectId, `%/${projectId}%`).first();

		if (!project) {
			// Auto-register new project
			await c.env.DEPLOYMENT_DB.prepare(
				'INSERT INTO projects (project_id, project_name, status) VALUES (?, ?, ?)'
			).bind(projectId, projectId, 'development').run();
		}

		// Get all resources for project
		const resources = await c.env.DEPLOYMENT_DB.prepare(
			'SELECT resource_type, resource_provider, resource_id, config FROM project_resources WHERE project_id = ?'
		).bind(projectId).all();

		return c.json({
			project: {
				id: projectId,
				name: project?.display_name || projectId,
				status: project?.status || 'development',
				github_repo: project?.github_repo
			},
			resources: resources.results,
			services: {
				auth0: `/api/auth0/config/${projectId}`,
				cloudflare: `/api/cloudflare/resources/${projectId}`,
				database: `/api/database/connection/${projectId}`
			}
		});

	} catch (error) {
		return c.json({
			error: 'Failed to fetch project configuration',
			message: error.message
		}, 500);
	}
}

/**
 * List all projects using this infrastructure service
 */
export async function listProjects(c: Context) {
	if (!c.env.DEPLOYMENT_DB) {
		return c.json({ error: 'Database not available' }, 503);
	}

	const projects = await c.env.DEPLOYMENT_DB.prepare(
		'SELECT project_id, project_name, display_name, github_repo, status, created_at FROM projects ORDER BY created_at DESC'
	).all();

	const stats = await c.env.DEPLOYMENT_DB.prepare(
		'SELECT resource_type, COUNT(*) as count FROM project_resources GROUP BY resource_type'
	).all();

	return c.json({
		projects: projects.results,
		total_projects: projects.results.length,
		resource_stats: stats.results,
		infrastructure_service: {
			url: 'https://terraform-infrastructure-container.joe-1a2.workers.dev',
			version: '1.0.0'
		}
	});
}
