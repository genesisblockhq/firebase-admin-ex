defmodule FirebaseAdminEx.Auth do
  alias FirebaseAdminEx.{Request, Response, Errors}
  alias FirebaseAdminEx.Auth.ActionCodeSettings

  @auth_endpoint_account "https://identitytoolkit.googleapis.com/v1/projects/"
  @auth_scope "https://www.googleapis.com/auth/cloud-platform"

  @doc """
  Create an email/password user
  """
  @spec create_user(String.t(), String.t(), String.t()) :: {:ok, map} | {:error, term}
  @spec create_user(String.t(), String.t(), String.t() | nil, String.t()) ::
          {:ok, map} | {:error, term}
  def create_user(email, password, client_email \\ nil, project_id) do
    payload = %{
      email: email,
      password: password,
      returnSecureToken: false
    }

    do_request("accounts", payload, client_email, project_id)
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

  defp do_request(url_suffix, payload, client_email, project_id) do
    with {:ok, response} <-
           Request.request(
             :post,
             "#{@auth_endpoint_account}#{project_id}/#{url_suffix}",
             payload,
             auth_header(client_email)
           ),
         {:ok, body} <- Response.parse(response) do
      {:ok, body}
    else
      {:error, error} -> raise Errors.ApiError, Kernel.inspect(error)
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
