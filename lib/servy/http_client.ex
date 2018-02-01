defmodule Servy.HttpClient do

  def send_request() do
    host = 'localhost'
    {:ok, socket} = :gen_tcp.connect(host, 4000, [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(socket, """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """)
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)
    msg
  end

end