import { Webhook } from 'convex/nextjs';
import { WebhookEvent } from '@clerk/nextjs/server';
import { NextResponse } from 'next/server';
import { api } from '../../../../convex/_generated/api';

export async function POST(req: Request) {
  const payload = await req.json();
  const webhook = new Webhook({ endpoint: api.auth.clerk });

  try {
    const { type, data } = payload as WebhookEvent;
    await webhook.send({ type, data });
    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error processing Clerk webhook:', error);
    return NextResponse.json({ success: false }, { status: 400 });
  }
}
