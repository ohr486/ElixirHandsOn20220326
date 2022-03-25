defmodule ExDemo.Echo3 do
  require Logger

  def start(port \\ 8080) do
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
    case read_line(accept_sock) do
      :closed ->
        :gen_tcp.close(accept_sock)
      "quit" ->
        Logger.info "# quit server"
        :timer.sleep(1000)
        System.halt
      msg ->
        write_line(msg, accept_sock)
        serve(accept_sock)
    end
  end

  def read_line(accept_sock) do
    case :gen_tcp.recv(accept_sock, 0) do
      {:ok, raw_msg} ->
        msg = String.trim(raw_msg)
        Logger.info "# read line ===> #{msg}"
        msg
      {:error, :closed} ->
        Logger.info "# read line ===> closed message"
        :closed
    end
  end

  def write_line(msg, accept_sock) do
    Logger.info "# write line ===> #{msg}"
    :gen_tcp.send(accept_sock, msg)
  end
end
