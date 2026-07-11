export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://127.0.0.1:8080/api/v1';

// Token Management
export const getAuthToken = () => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('rh_token');
    return (token && token !== 'undefined' && token !== 'null') ? token : null;
  }
  return null;
};

export const getRefreshToken = () => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('rh_refresh_token');
    return (token && token !== 'undefined' && token !== 'null') ? token : null;
  }
  return null;
};

export const setAuthToken = (token: string, refreshToken?: string) => {
  if (typeof window !== 'undefined') {
    localStorage.setItem('rh_token', token);
    if (refreshToken) {
      localStorage.setItem('rh_refresh_token', refreshToken);
    }
  }
};

export const clearAuthToken = () => {
  if (typeof window !== 'undefined') {
    localStorage.removeItem('rh_token');
    localStorage.removeItem('rh_refresh_token');
  }
};

export async function fetchWithAuth(endpoint: string, options: RequestInit = {}) {
  const headers = new Headers(options.headers);
  headers.set('Content-Type', 'application/json');
  
  const token = getAuthToken();
  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  let response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  if (!response.ok) {
    if (response.status === 401) {
      // Try to refresh token
      const refreshToken = getRefreshToken();
      if (refreshToken && !endpoint.includes('/auth/refresh')) {
        try {
          const refreshRes = await fetch(`${API_BASE_URL}/auth/refresh`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ refreshToken })
          });
          
          if (refreshRes.ok) {
            const data = await refreshRes.json();
            setAuthToken(data.accessToken, data.refreshToken);
            
            // Retry original request
            headers.set('Authorization', `Bearer ${data.accessToken}`);
            response = await fetch(`${API_BASE_URL}${endpoint}`, {
              ...options,
              headers,
            });
            
            if (response.ok) {
              const text = await response.text();
              return text ? JSON.parse(text) : {};
            }
          }
        } catch (e) {
          console.error('Token refresh failed', e);
        }
      }

      // If refresh failed or no refresh token
      clearAuthToken();
      if (typeof window !== 'undefined' && !window.location.pathname.includes('/login')) {
        window.location.href = '/login';
      }
    }
    const errorData = await response.json().catch(() => null);
    throw new Error(errorData?.message || errorData?.error || `API Error: ${response.status}`);
  }

  // Handle empty responses
  const text = await response.text();
  return text ? JSON.parse(text) : {};
}

export async function fetchWithAuthMultipart(endpoint: string, formData: FormData, options: RequestInit = {}) {
  const headers = new Headers(options.headers);
  
  const token = getAuthToken();
  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  // NOTE: Do not set Content-Type for FormData, the browser will automatically set it 
  // with the correct boundary parameter.
  
  let response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    method: 'POST',
    body: formData,
    headers,
  });

  if (!response.ok) {
    if (response.status === 401) {
      // Try to refresh token
      const refreshToken = getRefreshToken();
      if (refreshToken) {
        try {
          const refreshRes = await fetch(`${API_BASE_URL}/auth/refresh`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ refreshToken })
          });
          
          if (refreshRes.ok) {
            const data = await refreshRes.json();
            setAuthToken(data.accessToken, data.refreshToken);
            
            // Retry original request
            headers.set('Authorization', `Bearer ${data.accessToken}`);
            response = await fetch(`${API_BASE_URL}${endpoint}`, {
              ...options,
              method: 'POST',
              body: formData,
              headers,
            });
            
            if (response.ok) {
              const text = await response.text();
              return text ? JSON.parse(text) : {};
            }
          }
        } catch (e) {
          console.error('Token refresh failed', e);
        }
      }

      clearAuthToken();
      if (typeof window !== 'undefined' && !window.location.pathname.includes('/login')) {
        window.location.href = '/login';
      }
    }
    const errorData = await response.json().catch(() => null);
    throw new Error(errorData?.message || errorData?.error || `API Error: ${response.status}`);
  }

  const text = await response.text();
  return text ? JSON.parse(text) : {};
}

export const api = {
  // Authentication
  auth: {
    me: () => fetchWithAuth('/users/me'),
    login: (data: any) => 
      fetchWithAuth('/auth/login', {
        method: 'POST',
        body: JSON.stringify(data)
      }),
    register: (data: any) => 
      fetchWithAuth('/auth/register', {
        method: 'POST',
        body: JSON.stringify(data)
      }),
    forgotPassword: (data: { email: string }) =>
      fetchWithAuth('/auth/forgot-password', {
        method: 'POST',
        body: JSON.stringify(data)
      }),
    verifyOtp: (data: { email: string, otp: string }) =>
      fetchWithAuth('/auth/register/verify', {
        method: 'POST',
        body: JSON.stringify(data)
      }),
    resetPassword: (data: any) =>
      fetchWithAuth('/auth/reset-password', {
        method: 'POST',
        body: JSON.stringify(data)
      }),
  },

  // Search
  search: (query: string, type?: string) => 
    fetchWithAuth(`/search?q=${encodeURIComponent(query)}${type ? `&type=${type}` : ''}`),
  
  // Workspaces
  workspaces: {
    getMyWorkspaces: (page = 0, size = 10) => 
      fetchWithAuth(`/workspaces/my?page=${page}&size=${size}`),
    getBySlug: (slug: string) => 
      fetchWithAuth(`/workspaces/slug/${slug}`),
    create: (data: any) => 
      fetchWithAuth('/workspaces', { method: 'POST', body: JSON.stringify(data) }),
    update: (id: string, data: any) =>
      fetchWithAuth(`/workspaces/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
    delete: (id: string) =>
      fetchWithAuth(`/workspaces/${id}`, { method: 'DELETE' }),
    getShareLink: (id: string) =>
      fetchWithAuth(`/workspaces/${id}/share-link`),
    getMembers: (workspaceId: string) =>
      fetchWithAuth(`/workspaces/${workspaceId}/members`),
    getPublic: (page = 0, size = 10) =>
      fetchWithAuth(`/workspaces/public?page=${page}&size=${size}`)
  },

  // Datasets
  datasets: {
    getByWorkspace: (workspaceId: string, page = 0, size = 10) => 
      fetchWithAuth(`/workspaces/${workspaceId}/datasets?page=${page}&size=${size}`),
    create: (workspaceId: string, data: any) => 
      fetchWithAuth(`/workspaces/${workspaceId}/datasets`, { method: 'POST', body: JSON.stringify(data) }),
    getPublic: (domainType?: string) => 
      fetchWithAuth(`/datasets${domainType ? `?domainType=${domainType}` : ''}`),
    getRecords: (datasetId: string, page = 0, size = 10) =>
      fetchWithAuth(`/datasets/${datasetId}/records?page=${page}&size=${size}`),
    createRecord: (datasetId: string, data: any) =>
      fetchWithAuth(`/datasets/${datasetId}/records`, { method: 'POST', body: JSON.stringify(data) }),
    updateRecord: (recordId: string, data: any) =>
      fetchWithAuth(`/records/${recordId}`, { method: 'PUT', body: JSON.stringify(data) }),
    deleteRecord: (recordId: string) =>
      fetchWithAuth(`/records/${recordId}`, { method: 'DELETE' }),
    getRecord: (recordId: string) =>
      fetchWithAuth(`/records/${recordId}`),
    uploadCsv: (datasetId: string, formData: FormData) =>
      fetchWithAuthMultipart(`/datasets/${datasetId}/upload-csv`, formData),
    delete: (datasetId: string) =>
      fetchWithAuth(`/datasets/${datasetId}`, { method: 'DELETE' }),
    publish: (datasetId: string) =>
      fetchWithAuth(`/datasets/${datasetId}/publish`, { method: 'POST' }),
    archive: (datasetId: string) =>
      fetchWithAuth(`/datasets/${datasetId}/archive`, { method: 'POST' }),
    updateSchema: (datasetId: string, data: any) =>
      fetchWithAuth(`/datasets/${datasetId}/schema`, { method: 'PUT', body: JSON.stringify(data) }),
    getSchema: (datasetId: string) =>
      fetchWithAuth(`/datasets/${datasetId}/schema`)
  },

  // Imports
  imports: {
    getWorkspaceImports: (workspaceId: string, page = 0, size = 20) =>
      fetchWithAuth(`/workspaces/${workspaceId}/imports?page=${page}&size=${size}`)
  },
  
  // Complaints
  complaints: {
    getComplaints: (sort: 'trending' | 'top' | 'new' = 'trending') => 
      fetchWithAuth(`/complaints?sort=${sort}`),
    getWorkspaceComplaints: (workspaceId: string, sort: 'trending' | 'top' | 'new' = 'trending', page = 0, size = 20) => 
      fetchWithAuth(`/complaints/workspaces/${workspaceId}?sort=${sort}&page=${page}&size=${size}`),
    create: (formData: FormData) =>
      fetchWithAuthMultipart(`/complaints`, formData),
    getComments: (complaintId: string) =>
      fetchWithAuth(`/complaints/${complaintId}/comments`),
    addComment: (complaintId: string, content: string, parentCommentId?: string) =>
      fetchWithAuth(`/complaints/${complaintId}/comments`, {
        method: 'POST',
        body: JSON.stringify({ content, parentCommentId })
      }),
    upvote: (complaintId: string) =>
      fetchWithAuth(`/complaints/${complaintId}/upvote`, { method: 'POST' }),
    removeUpvote: (complaintId: string) =>
      fetchWithAuth(`/complaints/${complaintId}/upvote`, { method: 'DELETE' }),
    bookmark: (complaintId: string) =>
      fetchWithAuth(`/complaints/${complaintId}/bookmark`, { method: 'POST' }),
    removeBookmark: (complaintId: string) =>
      fetchWithAuth(`/complaints/${complaintId}/bookmark`, { method: 'DELETE' }),
  },
    
  // Votes / Polls
  votes: {
    getVoteBoxes: () =>
      fetchWithAuth(`/votes`),
    getWorkspaceVoteBoxes: (workspaceId: string, page = 0, size = 20) =>
      fetchWithAuth(`/votes/workspaces/${workspaceId}?page=${page}&size=${size}`),
    create: (data: any) =>
      fetchWithAuth(`/votes`, { method: 'POST', body: JSON.stringify(data) }),
    vote: (voteBoxId: string, optionId: string, deviceFingerprint?: string) =>
      fetchWithAuth(`/votes/${voteBoxId}/cast`, {
        method: 'POST',
        body: JSON.stringify({ optionId, deviceFingerprint })
      }),
  },
    
  // Analytics
  analytics: {
    getGlobalAnalytics: () => 
      fetchWithAuth(`/analytics/global`),
    getWorkspaceAnalytics: (workspaceId: string) =>
      fetchWithAuth(`/analytics/workspace/${workspaceId}`),
      
    // Comprehensive Analytics Module
    getDashboard: (workspaceId: string) => fetchWithAuth(`/analytics/workspaces/${workspaceId}/comprehensive/dashboard`),
    getSearch: (workspaceId: string) => fetchWithAuth(`/analytics/workspaces/${workspaceId}/comprehensive/search`),
    getUsers: (workspaceId: string) => fetchWithAuth(`/analytics/workspaces/${workspaceId}/comprehensive/users`),
    getDatasets: (workspaceId: string) => fetchWithAuth(`/analytics/workspaces/${workspaceId}/comprehensive/datasets`),
    getWorkspace: (workspaceId: string) => fetchWithAuth(`/analytics/workspaces/${workspaceId}/comprehensive/workspace`),
    getComplaints: (workspaceId: string) => fetchWithAuth(`/analytics/workspaces/${workspaceId}/comprehensive/complaints`),
    getPolls: (workspaceId: string) => fetchWithAuth(`/analytics/workspaces/${workspaceId}/comprehensive/polls`),
    getCommunity: (workspaceId: string) => fetchWithAuth(`/analytics/workspaces/${workspaceId}/comprehensive/community`),
    getPerformance: (workspaceId: string) => fetchWithAuth(`/analytics/workspaces/${workspaceId}/comprehensive/performance`),
  },

  // Social & Feed
  feed: {
    getTimeline: (cursor?: string, size = 20) =>
      fetchWithAuth(`/feed?size=${size}${cursor ? `&cursor=${cursor}` : ''}`)
  },
  
  posts: {
    getWorkspacePosts: (workspaceId: string, page = 0, size = 20) =>
      fetchWithAuth(`/posts/workspaces/${workspaceId}?page=${page}&size=${size}`),
    get: (postId: string) =>
      fetchWithAuth(`/posts/${postId}`),
    getComments: (postId: string) =>
      fetchWithAuth(`/posts/${postId}/comments`),
    addComment: (postId: string, content: string, parentCommentId?: string) =>
      fetchWithAuth(`/posts/${postId}/comments`, {
        method: 'POST',
        body: JSON.stringify({ content, parentCommentId })
      }),
    create: (formData: FormData) =>
      fetchWithAuthMultipart(`/posts`, formData),
    bookmark: (postId: string) =>
      fetchWithAuth(`/posts/${postId}/bookmark`, { method: 'POST' }),
    removeBookmark: (postId: string) =>
      fetchWithAuth(`/posts/${postId}/bookmark`, { method: 'DELETE' }),
    upvote: (postId: string) =>
      fetchWithAuth(`/posts/${postId}/like`, { method: 'POST' }),
    removeUpvote: (postId: string) =>
      fetchWithAuth(`/posts/${postId}/like`, { method: 'DELETE' })
  },

  notifications: {
    get: (page = 0, size = 20) =>
      fetchWithAuth(`/notifications?page=${page}&size=${size}`)
  },

  bookmarks: {
    get: () =>
      fetchWithAuth(`/feed/saved`)
  },

  // User Profiles
  users: {
    getMe: () => fetchWithAuth('/users/me'),
    updateMe: (data: { name: string; bio?: string; website?: string; phoneNumber?: string; city?: string; profilePictureBase64?: string; coverPictureBase64?: string }) =>
      fetchWithAuth('/users/me', { method: 'PUT', body: JSON.stringify(data) }),
    getProfile: (userId: string) => fetchWithAuth(`/users/${userId}/profile`),
    getFollowers: (userId: string) => fetchWithAuth(`/users/${userId}/followers`),
    getFollowing: (userId: string) => fetchWithAuth(`/users/${userId}/following`),
    follow: (userId: string) => fetchWithAuth(`/users/${userId}/follow`, { method: 'POST' }),
    unfollow: (userId: string) => fetchWithAuth(`/users/${userId}/follow`, { method: 'DELETE' }),
    block: (userId: string) => fetchWithAuth(`/users/${userId}/block`, { method: 'POST' }),
    unblock: (userId: string) => fetchWithAuth(`/users/${userId}/block`, { method: 'DELETE' }),
  },

  // Super Admin
  admin: {
    getStats: () => fetchWithAuth('/admin/stats'),
    getSystemHealth: () => fetchWithAuth('/admin/system/health'),

    // Users
    getUsers: (query = '', role = '', page = 0, size = 20) =>
      fetchWithAuth(`/admin/users?query=${encodeURIComponent(query)}&role=${role}&page=${page}&size=${size}`),
    getUser: (userId: string) => fetchWithAuth(`/admin/users/${userId}`),
    suspendUser: (userId: string, suspend: boolean) =>
      fetchWithAuth(`/admin/users/${userId}/suspend?suspend=${suspend}`, { method: 'PUT' }),
    updateUserQuota: (userId: string, quota: number) =>
      fetchWithAuth(`/admin/users/${userId}/quota`, { method: 'PUT', body: JSON.stringify({ workspaceQuota: quota }) }),
    changeUserRole: (userId: string, role: string) =>
      fetchWithAuth(`/admin/users/${userId}/role`, { method: 'PUT', body: JSON.stringify({ role }) }),
    resetUserPassword: (userId: string, newPassword: string) =>
      fetchWithAuth(`/admin/users/${userId}/reset-password`, { method: 'POST', body: JSON.stringify({ newPassword }) }),
    deleteUser: (userId: string) =>
      fetchWithAuth(`/admin/users/${userId}`, { method: 'DELETE' }),

    // Workspaces
    getWorkspaces: (query = '', page = 0, size = 20) =>
      fetchWithAuth(`/admin/workspaces?query=${encodeURIComponent(query)}&page=${page}&size=${size}`),
    suspendWorkspace: (workspaceId: string, suspend: boolean) =>
      fetchWithAuth(`/admin/workspaces/${workspaceId}/suspend?suspend=${suspend}`, { method: 'PUT' }),
    deleteWorkspace: (workspaceId: string) =>
      fetchWithAuth(`/admin/workspaces/${workspaceId}`, { method: 'DELETE' }),

    // Complaints
    getComplaints: (page = 0, size = 20) =>
      fetchWithAuth(`/admin/complaints?page=${page}&size=${size}`),
    deleteComplaint: (complaintId: string) =>
      fetchWithAuth(`/admin/complaints/${complaintId}`, { method: 'DELETE' }),

    // Posts
    getPosts: (page = 0, size = 20) =>
      fetchWithAuth(`/admin/posts?page=${page}&size=${size}`),
    deletePost: (postId: string) =>
      fetchWithAuth(`/admin/posts/${postId}`, { method: 'DELETE' }),
  },
};

