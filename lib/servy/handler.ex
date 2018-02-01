defmodule Servy.Handler do

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam
  alias Servy.Fetcher

  @moduledoc "Handles HTTP requests."

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1, emojify: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 3]
  import Servy.View, only: [render: 3]

  @doc "Transforms the request into a response"
  def handle(request) do
   parse(request)
   |> rewrite_path() # |> log()
   |> route()
   |> track() # |> emojify()
   |> put_content_length()
   |> format_response()
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/404"} = conv) do
    counts = Servy.FourOhFourCounter.get_counts()
    %{ conv | resp_body: inspect(counts), status: 200 }
  end

  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do
    parent = self() # the request-handling process

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Fetcher.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Fetcher.get_result/1)

    where_is_bigfoot = Task.await(task)

    render(conv, "sensors.eex", [snapshots: snapshots, location: where_is_bigfoot])
  end

  def route(%Conv{ method: "GET", path: "/kaboom" } = conv) do
    raise "Kaboom!"
  end

  def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer |> :timer.sleep

    %{ conv | resp_body: "Awake!", status: 200 }
  end

  def route(%Conv{ method: "GET", path: "/about" } = conv) do
    @pages_path
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv, :html)
  end

  def route(%Conv{ method: "GET", path: "/pages/" <> name } = conv) do
    @pages_path
      |> Path.join("#{name}.md")
      |> File.read
      |> handle_file(conv, :md)
  end

  def route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | resp_body: "Bears, Lions, Tigers", status: 200 }
  end

  def route(%Conv{ method: "GET", path: "/bears" } = conv) do
    BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/api/bears" } = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{ path: path } = conv) do
    %{ conv | resp_body: "No #{path} here!", status: 404}
  end

  def put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{ conv | resp_headers: headers }
  end

  def format_response_headers(conv) do
    for {key, value} <- conv.resp_headers do
      "#{key}: #{value}\r"
    end |> Enum.sort() |> Enum.reverse() |> Enum.join("\n")
  end

  def format_response(%Conv{} = conv) do
    # TODO: Use values in the map to create an HTTP response string
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end
end