defmodule ExDemo.HttpServer do
  require Logger

  def accept(port \\ 8080) do
    {:ok, sock} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "start http server on #{port} port ..."
    loop_acceptor(sock)
  end

  def loop_acceptor(sock) do
    {:ok, client} = :gen_tcp.accept(sock)
    serve(client)
    loop_acceptor(sock)
  end

  def serve(sock) do
    case read_line(sock) do
      :continue -> serve(sock)
      :end -> response(sock)
    end
  end

  def read_line(sock) do
    {:ok, msg} = :gen_tcp.recv(sock, 0)
    Logger.info "# read line ===> #{msg}"

    case String.split(msg, " ") do
      [_method, _target, _ver] ->
        :continue
      [_field_key, _field_val] ->
        :continue
      _ ->
        :end
    end
  end

  def response(sock) do
    resp_msg = "HELLO WORLD!"
    resp_msg_len = resp_msg |> String.length

    msg =
"""
HTTP/1.1 200 OK
Content-Length: #{resp_msg_len}

#{resp_msg}
"""

    Logger.info "# write line ===> #{msg}"
    :gen_tcp.send(sock, msg)
    :gen_tcp.close(sock)
  end
end
