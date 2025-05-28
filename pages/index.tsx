/**
 * Main entry point for the AWS Deployment Demo application
 * This file defines the homepage with information about AWS deployment architecture
 */
import React from 'react';
import Head from 'next/head';
import { Auth } from '@/app/components/Auth';

/**
 * Home Component
 * Renders the main landing page for the AWS Deployment Demo
 * Includes architecture diagram, deployment steps, and AWS services information
 * @returns {JSX.Element} The rendered homepage
 */
export default function Home() {
  return (
    <div className="min-h-screen bg-background">
      {/* Head section with meta tags for SEO and page title */}
      <Head>
        <title>AWS Deployment Demo</title>
        <meta name="description" content="AWS deployment demo with Terraform" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      {/* Navigation and authentication header */}
      <Auth />

      <main className="container mx-auto py-10">
        <div className="max-w-4xl mx-auto bg-card rounded-lg shadow-md p-6 border border-border">
          <h1 className="text-3xl font-bold mb-6 text-center">AWS Deployment Demo</h1>

          <div className="space-y-6">
            {/* Architecture Overview Section */}
            <section>
              <h2 className="text-2xl font-semibold mb-3">Architecture Overview</h2>
              <div className="flex justify-center">
                <img
                  src="/aws_containerized_website_deployment.png"
                  alt="AWS Architecture"
                  className="max-w-full h-auto border border-border rounded-md"
                />
              </div>
            </section>

            {/* Deployment Steps Section - Lists the steps for AWS deployment */}
            <section>
              <h2 className="text-2xl font-semibold mb-3">Deployment Steps</h2>
              <ol className="list-decimal list-inside space-y-2 pl-4">
                <li>Dockerize the application</li>
                <li>Push Docker image to Amazon ECR</li>
                <li>Provision infrastructure with Terraform</li>
                <li>Deploy the application to ECS</li>
                <li>Configure CloudWatch monitoring</li>
                <li>Set up CI/CD with GitHub Actions</li>
              </ol>
            </section>

            {/* Key AWS Services Section - Shows the main AWS services used */}
            <section>
              <h2 className="text-2xl font-semibold mb-3">Key AWS Services</h2>
              <ul className="grid grid-cols-1 md:grid-cols-2 gap-3">
                <li className="p-3 bg-muted rounded-md">Amazon ECR for container registry</li>
                <li className="p-3 bg-muted rounded-md">Amazon ECS for container orchestration</li>
                <li className="p-3 bg-muted rounded-md">Amazon VPC for networking</li>
                <li className="p-3 bg-muted rounded-md">Application Load Balancer</li>
                <li className="p-3 bg-muted rounded-md">AWS IAM for security</li>
                <li className="p-3 bg-muted rounded-md">CloudWatch for monitoring</li>
              </ul>
            </section>
          </div>
        </div>
      </main>

      {/* Footer section with credits */}
      <footer className="py-6 text-center text-sm text-muted-foreground">
        <p>AWS Deployment Demo - Built with Next.js and Tailwind CSS</p>
      </footer>
    </div>
  );
}
