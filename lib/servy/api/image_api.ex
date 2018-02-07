defmodule Servy.ImageApi do
  def query(addr) do
    HTTPoison.get(URI.encode(addr))
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, extract(body, ["image", "image_url"])}

      {:ok, %HTTPoison.Response{status_code: _status, body: body}} ->
        {:error, extract(body, ["message"])}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp extract(body, path) do
    result =
      Poison.Parser.parse!(body)
      |> get_in(path)

    case result do
      nil -> "No #{List.last(path)} here!"
      _ -> result
    end
  end
end
