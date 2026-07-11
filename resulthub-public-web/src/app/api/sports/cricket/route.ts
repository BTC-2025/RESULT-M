import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const endpoint = searchParams.get('endpoint') || 'currentMatches';
  const offset = searchParams.get('offset') || '0';
  const id = searchParams.get('id');

  const apiKey = process.env.CRIC_API_KEY || '5fa39f8c-012c-4e3b-9072-ec5dc6a486ab';

  let path = '/currentMatches';
  if (endpoint === 'matches') path = '/matches';
  if (endpoint === 'match_info') path = '/match_info';

  const targetUrl = new URL(`https://api.cricapi.com/v1${path}`);
  targetUrl.searchParams.append('apikey', apiKey);
  targetUrl.searchParams.append('offset', offset);
  if (id) targetUrl.searchParams.append('id', id);

  try {
    const res = await fetch(targetUrl.toString(), {
      next: { revalidate: 60 } // Cache for 60 seconds
    });
    const data = await res.json();
    return NextResponse.json(data);
  } catch (error) {
    console.error('Cricket API proxy error:', error);
    return NextResponse.json({ status: 'failure', reason: 'Failed to fetch data' }, { status: 500 });
  }
}
