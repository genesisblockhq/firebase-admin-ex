defmodule FirebaseAdminEx.Auth do
  alias FirebaseAdminEx.{Request, Response}
  alias FirebaseAdminEx.Auth.ActionCodeSettings

  @auth_endpoint_account "https://identitytoolkit.googleapis.com/v1/projects/"
  @auth_scope "https://www.googleapis.com/auth/cloud-platform"

  @doc """
  Create an email/password user
  """
  @spec create_user(String.t(), String.t()) :: {:ok, map} | {:error, term}
  @spec create_user(String.t(), String.t(), String.t() | nil) :: {:ok, map} | {:error, term}
  @spec create_user(String.t(), String.t(), String.t() | nil, String.t() | nil) ::
          {:ok, map} | {:error, term}
  def create_user(email, password, client_email \\ nil, project_id \\ nil) do
    do_request("accounts", %{email: email, password: password}, client_email, project_id)
  end

  @spec update_user(String.t(), map) :: {:ok, map} | {:error, term}
  @spec update_user(String.t(), map, String.t() | nil) :: {:ok, map} | {:error, term}
  @spec update_user(String.t(), map, String.t() | nil, String.t() | nil) ::
          {:ok, map} | {:error, term}
  def update_user(uid, updates, client_email \\ nil, project_id \\ nil) do
    args = Map.put(updates, :localId, uid)
    do_request("accounts:update", args, client_email, project_id)
  end

  @doc """
  Generates the email action link for sign-in flows, using the action code settings provided
  """
  @spec generate_sign_in_with_email_link(ActionCodeSettings.t(), String.t(), String.t()) ::
          tuple()
  def generate_sign_in_with_email_link(action_code_settings, client_email, project_id) do
    with {:ok, action_code_settings} <- ActionCodeSettings.validate(action_code_settings) do
      do_request("accounts:sendOobCode", action_code_settings, client_email, project_id)
    end
  end

  defp do_request(url_suffix, payload, client_email, nil) do
    case Goth.Config.get(:project_id) do
      {:ok, project_id} -> do_request(url_suffix, payload, client_email, project_id)
      :error -> {:error, :missing_project_id}
    end
  end

  defp do_request(url_suffix, payload, client_email, project_id) do
    with {:ok, response} <-
           Request.request(
             :post,
             "#{@auth_endpoint_account}#{project_id}/#{url_suffix}",
             payload,
             auth_header(client_email)
           ) do
      Response.parse(response)
    end
  end

  defp auth_header(nil) do
    {:ok, token} = Goth.Token.for_scope(@auth_scope)

    do_auth_header(token.token)
  end

  defp auth_header(client_email) do
    {:ok, token} = Goth.Token.for_scope({client_email, @auth_scope})

    do_auth_header(token.token)
  end

  defp do_auth_header(token) do
    %{"Authorization" => "Bearer #{token}"}
  end
end
