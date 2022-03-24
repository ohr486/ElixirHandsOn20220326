defmodule ExDemo.EchoServer do
  require Logger

  def accept(port \\ 8080) do
    {:ok, listen_sock} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "start echo server on #{port} port ..."
    loop_acceptor(listen_sock)
  end

  def loop_acceptor(listen_sock) do
    {:ok, accept_sock} = :gen_tcp.accept(listen_sock)
    serve(accept_sock)
    loop_acceptor(listen_sock)
  end

  def serve(accept_sock) do
    msg = read_line(accept_sock)
    write_line(msg, accept_sock)

    serve(accept_sock)
  end

  def read_line(accept_sock) do
    {:ok, msg} = :gen_tcp.recv(accept_sock, 0)
    Logger.info "# read line ===> #{msg}"
    msg
  end

  def write_line(msg, accept_sock) do
    Logger.info "# write line ===> #{msg}"
    :gen_tcp.send(accept_sock, msg)
  end
end
