defmodule FirebaseAdminEx.Response do
  def parse(%HTTPoison.Response{} = response) do
    case response do
      %HTTPoison.Response{status_code: 200, body: body} ->
        case Jason.decode(body) do
          {:ok, _} = decoded -> decoded
          {:error, _} -> {:ok, body}
        end

      %HTTPoison.Response{status_code: status, body: body} ->
        case Jason.decode(body) do
          {:ok, %{"error" => error}} -> {:error, error}
          {:ok, resp} -> {:error, {:unexpected_response, status, resp}}
          {:error, _} -> {:error, {:unexpected_response, status, body}}
        end
    end
  end

  def parse(_response) do
    {:error, "Invalid response"}
  end
end
