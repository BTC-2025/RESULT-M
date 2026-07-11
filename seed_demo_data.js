const base_url = 'http://127.0.0.1:8080/api/v1';

async function api(path, method, data = null, token = null) {
  const headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  
  const options = { method, headers };
  if (data) {
    options.body = JSON.stringify(data);
  }
  
  const res = await fetch(`${base_url}${path}`, options);
  if (!res.ok) {
    const text = await res.text();
    console.error(`Error ${res.status}: ${text}`);
    return null;
  }
  return res.json();
}

async function main() {
  console.log('--- Seeding Demo Data ---');

  const email = `admin_${Date.now()}@demo.com`;
  const password = "password123";

  console.log(`\n1. Creating Admin User (${email})...`);
  await api('/auth/register', 'POST', {
      name: 'Demo Admin',
      email: email,
      password: password
  });

  console.log("Logging in...");
  const loginRes = await api('/auth/login', 'POST', {
      email: email,
      password: password
  });

  if (!loginRes || (!loginRes.token && !loginRes.accessToken)) {
      console.log("Login failed!", loginRes);
      process.exit(1);
  }

  const token = loginRes.token || loginRes.accessToken;

  // 2. Anna University
  console.log('\n2. Creating Academic Workspace...');
  const ws1 = await api('/workspaces', 'POST', {
      name: 'Anna University',
      slug: `anna-university-${Date.now()}`,
      description: 'Official portal for university results and announcements.',
      domainType: 'EDUCATION',
      visibility: 'PUBLIC'
  }, token);
  
  console.log('Creating Academic Dataset...');
  const ds1 = await api(`/workspaces/${ws1.id}/datasets`, 'POST', {
      name: 'B.E/B.Tech Nov/Dec 2025 Results',
      slug: `btech-nov-dec-2025-${Date.now()}`,
      description: 'UG Degree Examination Results',
      domainType: 'EDUCATION'
  }, token);

  console.log('Publishing Dataset...');
  await api(`/datasets/${ds1.id}`, 'PUT', {
      name: 'B.E/B.Tech Nov/Dec 2025 Results',
      slug: `btech-nov-dec-2025-${Date.now()}`,
      description: 'UG Degree Examination Results',
      domainType: 'EDUCATION',
      status: 'PUBLISHED'
  }, token);

  console.log('Inserting Academic Records...');
  await api(`/datasets/${ds1.id}/records`, 'POST', {
      recordKey: '1928374',
      recordTitle: 'Rahul Kumar',
      tags: ['CS', 'Pass'],
      data: {
          'Name': 'Rahul Kumar',
          'Roll Number': '1928374',
          'Department': 'Computer Science',
          'GPA': 8.9,
          'Result': 'PASS'
      }
  }, token);

  await api(`/datasets/${ds1.id}/records`, 'POST', {
      recordKey: '1928375',
      recordTitle: 'Priya Sharma',
      tags: ['EE', 'Pass'],
      data: {
          'Name': 'Priya Sharma',
          'Roll Number': '1928375',
          'Department': 'Electrical Engineering',
          'GPA': 9.2,
          'Result': 'PASS'
      }
  }, token);

  // 3. IPL 2026
  console.log('\n3. Creating Sports Workspace...');
  const ws2 = await api('/workspaces', 'POST', {
      name: 'IPL 2026',
      slug: `ipl-2026-${Date.now()}`,
      description: 'Official Live Scores for Indian Premier League',
      domainType: 'SPORTS',
      visibility: 'PUBLIC'
  }, token);

  console.log('Creating Sports Dataset...');
  const ds2 = await api(`/workspaces/${ws2.id}/datasets`, 'POST', {
      name: 'Match 47: MI vs CSK',
      slug: `match-47-mi-csk-${Date.now()}`,
      description: 'Live ball-by-ball updates',
      domainType: 'SPORTS'
  }, token);

  await api(`/datasets/${ds2.id}`, 'PUT', {
      name: 'Match 47: MI vs CSK',
      slug: `match-47-mi-csk-${Date.now()}`,
      description: 'Live ball-by-ball updates',
      domainType: 'SPORTS',
      status: 'PUBLISHED'
  }, token);

  console.log('Inserting Sports Records...');
  await api(`/datasets/${ds2.id}/records`, 'POST', {
      recordKey: 'inn2_ov15',
      recordTitle: 'Over 15.2',
      tags: ['LIVE', 'Boundary'],
      data: {
          'Innings': 2,
          'Batting Team': 'MI',
          'Score': '186/4',
          'Batsman': 'Rohit Sharma (72*)',
          'Bowler': 'Ravindra Jadeja',
          'Commentary': 'FOUR! Swept perfectly in the gap.',
          'Target': 232
      }
  }, token);

  // 4. TN Election Commission
  console.log('\n4. Creating Government Workspace...');
  const ws3 = await api('/workspaces', 'POST', {
      name: 'TN Election Commission',
      slug: `tn-election-${Date.now()}`,
      description: 'Live Election Counting 2026',
      domainType: 'POLITICS',
      visibility: 'PUBLIC'
  }, token);

  console.log('Creating Election Dataset...');
  const ds3 = await api(`/workspaces/${ws3.id}/datasets`, 'POST', {
      name: 'Chennai South Constituency',
      slug: `chennai-south-2026-${Date.now()}`,
      description: 'Assembly Election Live Counts',
      domainType: 'POLITICS'
  }, token);

  await api(`/datasets/${ds3.id}`, 'PUT', {
      name: 'Chennai South Constituency',
      slug: `chennai-south-2026-${Date.now()}`,
      description: 'Assembly Election Live Counts',
      domainType: 'POLITICS',
      status: 'PUBLISHED'
  }, token);

  console.log('Inserting Election Records...');
  await api(`/datasets/${ds3.id}/records`, 'POST', {
      recordKey: 'round_12',
      recordTitle: 'Round 12 Counting',
      tags: ['Counting', 'Update'],
      data: {
          'Candidate 1 (DMK)': 45200,
          'Candidate 2 (AIADMK)': 32150,
          'Candidate 3 (NTK)': 8400,
          'Status': 'Counting in Progress',
          'Leading': 'DMK (+13,050)'
      }
  }, token);

  console.log('\n--- Demo Data Seeding Completed ---');
}

main().catch(console.error);
