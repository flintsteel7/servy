defmodule Servy.Api.BearController do

  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!

    conv = put_resp_content_type(conv, "application/json")
    %{ conv | resp_body: json, status: 200 }
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{ conv | resp_body: "Created a #{type} bear named #{name}!", status: 201}
  end

  def put_resp_content_type(conv, type) do
    headers = Map.put(conv.resp_headers, "Content-Type", type)
    %{ conv | resp_headers: headers }
  end

end
"""
HTTP/1.1 201 Created\r
Content-Type: text/html\r
Content-Length: 35\r
\r
Created a Polar bear named Breezly!
"""