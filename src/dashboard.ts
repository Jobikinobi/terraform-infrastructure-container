/**
 * HOLE Substrate Dashboard
 * Simple HTML dashboard for visualizing infrastructure
 */

import { Context } from 'hono';

export async function renderDashboard(c: Context) {
	// Fetch data from D1
	const [repos, tasks, gitEvents, webhookStats] = await Promise.all([
		c.env.DEPLOYMENT_DB?.prepare('SELECT COUNT(*) as count FROM github_repositories').first(),
		c.env.DEPLOYMENT_DB?.prepare('SELECT COUNT(*) as count FROM project_tasks WHERE state = "open"').first(),
		c.env.DEPLOYMENT_DB?.prepare('SELECT * FROM git_events ORDER BY timestamp DESC LIMIT 10').all(),
		c.env.DEPLOYMENT_DB?.prepare('SELECT event_type, COUNT(*) as count FROM webhook_events GROUP BY event_type').all()
	]);

	const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HOLE Substrate Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        // Auto-refresh every 30 seconds
        setTimeout(() => location.reload(), 30000);
    </script>
</head>
<body class="bg-gray-50">
    <div class="container mx-auto p-8">
        <!-- Header -->
        <div class="mb-8">
            <h1 class="text-4xl font-bold text-gray-900 mb-2">HOLE Substrate</h1>
            <p class="text-gray-600">The foundational infrastructure layer for HOLE Foundation</p>
        </div>

        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <div class="bg-white rounded-lg shadow p-6">
                <div class="text-sm font-medium text-gray-500 mb-1">Repositories</div>
                <div class="text-3xl font-bold text-blue-600">${repos?.count || 0}</div>
                <div class="text-xs text-gray-400 mt-1">Tracked via webhooks</div>
            </div>

            <div class="bg-white rounded-lg shadow p-6">
                <div class="text-sm font-medium text-gray-500 mb-1">Open Tasks</div>
                <div class="text-3xl font-bold text-green-600">${tasks?.count || 0}</div>
                <div class="text-xs text-gray-400 mt-1">GitHub issues</div>
            </div>

            <div class="bg-white rounded-lg shadow p-6">
                <div class="text-sm font-medium text-gray-500 mb-1">Cloud Providers</div>
                <div class="text-3xl font-bold text-purple-600">4</div>
                <div class="text-xs text-gray-400 mt-1">Azure, Cloudflare, Auth0, GitHub</div>
            </div>

            <div class="bg-white rounded-lg shadow p-6">
                <div class="text-sm font-medium text-gray-500 mb-1">Webhook Events</div>
                <div class="text-3xl font-bold text-orange-600">${webhookStats?.results.reduce((sum: number, r: any) => sum + r.count, 0) || 0}</div>
                <div class="text-xs text-gray-400 mt-1">Total events logged</div>
            </div>
        </div>

        <!-- Recent Activity -->
        <div class="bg-white rounded-lg shadow mb-8">
            <div class="border-b border-gray-200 px-6 py-4">
                <h2 class="text-xl font-bold text-gray-900">Recent Git Activity</h2>
            </div>
            <div class="divide-y divide-gray-200">
                ${gitEvents?.results.map((event: any) => `
                    <div class="px-6 py-4 hover:bg-gray-50">
                        <div class="flex items-start">
                            <div class="flex-1">
                                <div class="flex items-center gap-2">
                                    <span class="font-medium text-gray-900">${event.author}</span>
                                    <span class="text-gray-500">→</span>
                                    <span class="text-sm text-gray-600">${event.branch}</span>
                                </div>
                                <p class="text-sm text-gray-700 mt-1">${event.commit_message?.split('\n')[0] || ''}</p>
                                <p class="text-xs text-gray-400 mt-1">${new Date(event.timestamp).toLocaleString()}</p>
                            </div>
                        </div>
                    </div>
                `).join('') || '<div class="px-6 py-4 text-gray-500">No recent activity</div>'}
            </div>
        </div>

        <!-- Webhook Stats -->
        <div class="bg-white rounded-lg shadow">
            <div class="border-b border-gray-200 px-6 py-4">
                <h2 class="text-xl font-bold text-gray-900">Webhook Events</h2>
            </div>
            <div class="p-6">
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                    ${webhookStats?.results.map((stat: any) => `
                        <div class="text-center">
                            <div class="text-2xl font-bold text-gray-900">${stat.count}</div>
                            <div class="text-sm text-gray-500">${stat.event_type}</div>
                        </div>
                    `).join('') || ''}
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="mt-8 text-center text-gray-500 text-sm">
            <p>HOLE Substrate v1.0.0 • Auto-refreshes every 30s</p>
            <p class="mt-2">
                <a href="/api/services" class="text-blue-600 hover:underline">API Documentation</a> •
                <a href="https://github.com/Jobikinobi/terraform-infrastructure-container" class="text-blue-600 hover:underline">GitHub</a>
            </p>
        </div>
    </div>
</body>
</html>
	`;

	return c.html(html);
}
