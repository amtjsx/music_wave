"use client";

// This is an enhanced API client that handles token refresh and supports FormData
const API_URL = process.env.NEXT_PUBLIC_API_URL;

class ApiClient {
  private accessToken: string | null = null;

  // Set the access token in memory
  private setAccessToken(token: string): void {
    this.accessToken = token;
  }

  // Clear the access token from memory
  private clearAccessToken(): void {
    this.accessToken = null;
  }

  // Make a request with the access token
  private async request<T>(
    endpoint: string,
    options: RequestInit & {
      params?: Record<string, string | number | boolean | undefined>;
      isFormData?: boolean;
    } = {}
  ): Promise<T | boolean> {
    const url = new URL(`${API_URL}${endpoint}`);

    if (options.params) {
      Object.entries(options.params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          url.searchParams.append(key, String(value));
        }
      });
    }

    // Don't set Content-Type for FormData (browser will set it with boundary)
    const headers: HeadersInit = options.isFormData
      ? { ...options.headers }
      : {
          "Content-Type": "application/json",
          ...options.headers,
        };

    // Add authorization header if we have a token
    // if (this.accessToken) {
    //   headers["Authorization"] = `Bearer ${this.accessToken}`;
    // }

    const config: RequestInit = {
      ...options,
      headers: headers as HeadersInit,
      credentials: "include", // Important for cookies (refresh token)
    };

    console.log("Request config:", {
      url: url.toString(),
      method: config.method,
      isFormData: options.isFormData,
    });

    const response = await fetch(url.toString(), config);

    console.log("Response status:", response.status);

    // Handle 401 Unauthorized - attempt to refresh token
    if (response.status === 401) {
      const refreshed = await this.refreshToken();
      if (refreshed) {
        console.log("Token refreshed. Retrying request...");
        return this.request(endpoint, options);
      } else {
        throw new Error("Session expired. Please login again.");
      }
    }

    if (!response.ok) {
      const errorText = await response.text();
      let errorMessage = "API request failed";

      try {
        const errorData = JSON.parse(errorText);
        errorMessage = errorData.message || errorMessage;
      } catch {
        // Not a JSON response
        errorMessage = errorText || errorMessage;
      }

      console.log("Error message:", errorMessage);
      throw new Error(errorMessage);
    }

    if (config.method === "DELETE") return null as any;

    // Check if response is empty
    const contentType = response.headers.get("content-type");
    if (contentType && contentType.includes("application/json")) {
      const body = await response.json();
      return body;
    } else {
      // For non-JSON responses or empty responses
      return true as any;
    }
  }

  // Refresh the access token using the refresh token (in HTTP-only cookie)
  private async refreshToken(): Promise<boolean> {
    try {
      const response = await fetch(`${API_URL}/auth/refresh`, {
        method: "POST",
        credentials: "include", // Important for cookies
        body: JSON.stringify({ s_id: this.accessToken }),
      });
      const data = await response.json();
      console.log("Refresh response:", data);

      if (data.status === 401) {
        this.clearAccessToken();
        return false;
      }
      if (!response.ok) {
        this.clearAccessToken();
        return false;
      }

      this.setAccessToken(data.accessToken);
      return true;
    } catch (error) {
      console.log("Refresh error:", error);
      this.clearAccessToken();
      return false;
    }
  }

  // Public methods
  async get<T = any>(
    endpoint: string,
    options?: RequestInit & {
      params?: Record<string, string | number | boolean | undefined>;
    }
  ): Promise<T | boolean> {
    return this.request<T>(endpoint, { method: "GET", ...options });
  }

  async post<T = any>(endpoint: string, data?: any): Promise<T | boolean> {
    // Check if data is FormData
    const isFormData = data instanceof FormData;

    return this.request<T>(endpoint, {
      method: "POST",
      body: isFormData ? data : data ? JSON.stringify(data) : undefined,
      isFormData,
    });
  }

  // Specific method for FormData uploads
  async uploadForm<T = any>(
    endpoint: string,
    formData: FormData
  ): Promise<T | boolean> {
    return this.request<T>(endpoint, {
      method: "POST",
      body: formData,
      isFormData: true,
    });
  }

  async patch<T = any>(endpoint: string, data?: any): Promise<T | boolean> {
    // Check if data is FormData
    const isFormData = data instanceof FormData;

    return this.request<T>(endpoint, {
      method: "PATCH",
      body: isFormData ? data : data ? JSON.stringify(data) : undefined,
      isFormData,
    });
  }

  async delete<T = any>(
    endpoint: string,
    options?: RequestInit
  ): Promise<T | boolean> {
    return this.request<T>(endpoint, { method: "DELETE", ...options });
  }

  // Set initial access token (e.g., after login)
  setToken(token: string): void {
    this.setAccessToken(token);
  }

  // Clear tokens (e.g., for logout)
  clearTokens(): void {
    this.clearAccessToken();
  }
}

export const apiClient = new ApiClient();
