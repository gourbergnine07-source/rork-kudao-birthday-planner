/* eslint-disable */
// AUTO-GENERATED — DO NOT EDIT
// Run migrations to regenerate.

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.15"
  }
  public: {
    Tables: {
      cloud_accounts: {
        Row: {
          code_hash: string
          created_at: string
          device_label: string
          id: string
          last_seen_at: string
        }
        Insert: {
          code_hash: string
          created_at?: string
          device_label?: string
          id?: string
          last_seen_at?: string
        }
        Update: {
          code_hash?: string
          created_at?: string
          device_label?: string
          id?: string
          last_seen_at?: string
        }
        Relationships: []
      }
      cloud_diary_entries: {
        Row: {
          account_id: string
          author_name: string
          author_user_id: string
          created_at: string
          deleted_at: string | null
          id: string
          is_remote: boolean
          profile_id: string
          text_content: string
          updated_at: string
        }
        Insert: {
          account_id: string
          author_name?: string
          author_user_id?: string
          created_at?: string
          deleted_at?: string | null
          id: string
          is_remote?: boolean
          profile_id: string
          text_content?: string
          updated_at?: string
        }
        Update: {
          account_id?: string
          author_name?: string
          author_user_id?: string
          created_at?: string
          deleted_at?: string | null
          id?: string
          is_remote?: boolean
          profile_id?: string
          text_content?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "cloud_diary_entries_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "cloud_accounts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cloud_diary_entries_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "cloud_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      cloud_profiles: {
        Row: {
          account_id: string
          address: string
          birth_date: string
          contact_email: string
          contact_phone: string
          created_at: string
          deleted_at: string | null
          favorite_character: string
          gift_reminder_days_before: number
          gift_reminder_enabled: boolean
          id: string
          is_surprise_mode: boolean
          last_name: string
          message: Json | null
          name: string
          photo_base64: string | null
          plan: Json | null
          relationship: string
          reminder_days_before: number
          reminder_enabled: boolean
          updated_at: string
        }
        Insert: {
          account_id: string
          address?: string
          birth_date: string
          contact_email?: string
          contact_phone?: string
          created_at?: string
          deleted_at?: string | null
          favorite_character?: string
          gift_reminder_days_before?: number
          gift_reminder_enabled?: boolean
          id: string
          is_surprise_mode?: boolean
          last_name?: string
          message?: Json | null
          name?: string
          photo_base64?: string | null
          plan?: Json | null
          relationship?: string
          reminder_days_before?: number
          reminder_enabled?: boolean
          updated_at?: string
        }
        Update: {
          account_id?: string
          address?: string
          birth_date?: string
          contact_email?: string
          contact_phone?: string
          created_at?: string
          deleted_at?: string | null
          favorite_character?: string
          gift_reminder_days_before?: number
          gift_reminder_enabled?: boolean
          id?: string
          is_surprise_mode?: boolean
          last_name?: string
          message?: Json | null
          name?: string
          photo_base64?: string | null
          plan?: Json | null
          relationship?: string
          reminder_days_before?: number
          reminder_enabled?: boolean
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "cloud_profiles_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "cloud_accounts"
            referencedColumns: ["id"]
          },
        ]
      }
      gallery_items: {
        Row: {
          byte_size: number
          caption: string | null
          committed: boolean
          created_at: number
          duration: number
          id: string
          inserted_at: string
          item_id: string
          media_type: string
          mime: string
          room_id: string
          storage_path: string
          thumbnail_base64: string | null
          updated_at: string
          uploaded_by: string
          uploader_name: string
        }
        Insert: {
          byte_size?: number
          caption?: string | null
          committed?: boolean
          created_at: number
          duration?: number
          id?: string
          inserted_at?: string
          item_id: string
          media_type?: string
          mime?: string
          room_id: string
          storage_path: string
          thumbnail_base64?: string | null
          updated_at?: string
          uploaded_by: string
          uploader_name?: string
        }
        Update: {
          byte_size?: number
          caption?: string | null
          committed?: boolean
          created_at?: number
          duration?: number
          id?: string
          inserted_at?: string
          item_id?: string
          media_type?: string
          mime?: string
          room_id?: string
          storage_path?: string
          thumbnail_base64?: string | null
          updated_at?: string
          uploaded_by?: string
          uploader_name?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      kudao_code_hash: { Args: { p_code: string }; Returns: string }
      kudao_create_vault: {
        Args: { p_code: string; p_label?: string }
        Returns: Json
      }
      kudao_forget_vault: { Args: { p_code: string }; Returns: Json }
      kudao_sync_vault: {
        Args: { p_code: string; p_entries?: Json; p_profiles?: Json }
        Returns: Json
      }
      user_id: { Args: never; Returns: string }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
