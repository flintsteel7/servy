defmodule HttpServerTest do
  use ExUnit.Case, async: true

  import Servy.HttpServer, only: [start: 1]
  import Servy.HttpClient, only: [send_request: 0]

  test "Http Server Concurrency with Task" do
    pid = spawn(fn -> start(4003) end)

    [
      "http://localhost:4003/wildthings",
      "http://localhost:4003/bears",
      "http://localhost:4003/about",
      "http://localhost:4003/wildlife",
      "http://localhost:4003/pages/faq"
    ]
    |> Enum.map(&Task.async(fn -> HTTPoison.get(&1) end))
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assertions/1)

    Process.exit(pid, :normal)
  end

  defp assertions({_, response}) do
    assert response.status_code == 200
  end

  test "Http Server Concurrency" do
    pid = spawn(fn -> start(4002) end)

    # the request-handling process
    parent = self()

    for _ <- 1..5 do
      spawn(fn ->
        {_, response} = HTTPoison.get("http://localhost:4002/wildthings")
        send(parent, {:ok, response})
      end)
    end

    for _ <- 1..5 do
      receive do
        {:ok, response} ->
          assert response.status_code == 200
          assert response.body == "Bears, Lions, Tigers"
      end
    end

    Process.exit(pid, :normal)
  end

  test "Http Server with HTTPoison" do
    pid = spawn(fn -> start(4001) end)

    {_, response} = HTTPoison.get("http://localhost:4001/wildthings")

    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers"

    Process.exit(pid, :normal)
  end

  test "Http Server with Http Client" do
    pid = spawn(fn -> start(4000) end)

    response = send_request()

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 335\r
    \r
    <h1>All The Bears!</h1>

    <ul>
      <li>Brutus - Grizzly</li>
      <li>Iceman - Polar</li>
      <li>Kenai - Grizzly</li>
      <li>Paddington - Brown</li>
      <li>Roscoe - Panda</li>
      <li>Rosie - Black</li>
      <li>Scarface - Grizzly</li>
      <li>Smokey - Black</li>
      <li>Snow - Polar</li>
      <li>Teddy - Brown</li>
    </ul>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)

    Process.exit(pid, :normal)
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end
end
