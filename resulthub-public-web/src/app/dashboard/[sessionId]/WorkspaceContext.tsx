"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { api, getAuthToken } from "@/lib/api";

type WorkspaceContextType = {
  activeWorkspace: any;
  setActiveWorkspace: (workspace: any) => void;
  workspaces: any[];
  isLoading: boolean;
};

const WorkspaceContext = createContext<WorkspaceContextType>({
  activeWorkspace: null,
  setActiveWorkspace: () => {},
  workspaces: [],
  isLoading: true,
});

export const WorkspaceProvider = ({ children }: { children: React.ReactNode }) => {
  const [workspaces, setWorkspaces] = useState<any[]>([]);
  const [activeWorkspace, setActiveWorkspace] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const token = getAuthToken();
    if (!token) {
      setIsLoading(false);
      return;
    }

    const loadWorkspaces = async () => {
      try {
        const response = await api.workspaces.getMyWorkspaces(0, 50);
        if (response.content) {
          setWorkspaces(response.content);
          if (response.content.length > 0) {
            setActiveWorkspace(response.content[0]);
          }
        }
      } catch (err) {
        console.error("Failed to load workspaces", err);
      } finally {
        setIsLoading(false);
      }
    };
    
    loadWorkspaces();
  }, []);

  return (
    <WorkspaceContext.Provider value={{ activeWorkspace, setActiveWorkspace, workspaces, isLoading }}>
      {children}
    </WorkspaceContext.Provider>
  );
};

export const useWorkspace = () => useContext(WorkspaceContext);
