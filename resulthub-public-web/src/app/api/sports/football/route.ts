import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const type = searchParams.get('type') || 'matches';
  const sport = searchParams.get('sport') || 'football';
  const status = searchParams.get('status');
  const date = searchParams.get('date');
  const id = searchParams.get('id');

  const apiKey = process.env.SPORTSRC_V2_KEY || '';

  const targetUrl = new URL('https://api.sportsrc.org/v2/');
  if (type) targetUrl.searchParams.append('type', type);
  if (sport) targetUrl.searchParams.append('sport', sport);
  if (status) targetUrl.searchParams.append('status', status);
  if (date) targetUrl.searchParams.append('date', date);
  if (id) targetUrl.searchParams.append('id', id);

  try {
    const res = await fetch(targetUrl.toString(), {
      headers: {
        'X-API-KEY': apiKey
      },
      next: { revalidate: 60 } // Cache for 60 seconds
    });
    const data = await res.json();
    return NextResponse.json(data);
  } catch (error) {
    console.error('Football API proxy error:', error);
    return NextResponse.json({ success: false, message: 'Failed to fetch data' }, { status: 500 });
  }
}
