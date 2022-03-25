defmodule ExDemo.Http2 do
  require Logger

  def start(port \\ 8080) do
    {:ok, listen_sock} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "start http server (2) on #{port} port ..."
    loop_acceptor(listen_sock)
  end

  def loop_acceptor(listen_sock) do
    {:ok, accept_sock} = :gen_tcp.accept(listen_sock)
    serve(accept_sock)
    loop_acceptor(listen_sock)
  end

  # conn(Map)に、リクエスト情報を保持しながら処理(serve)
  def serve(accept_sock, conn \\ %{}) do
    case read_req(accept_sock) do
      {:req_line, method, target, prot_ver} ->
        # connにリクエストラインの情報をput
        conn = conn
               |> Map.put(:method, method)
               |> Map.put(:target, target)
               |> Map.put(:prot_ver, prot_ver)
        serve(accept_sock, conn)
      {:header_line, header_field, header_val} ->
        # connにヘッダ情報をput
        conn = conn
               |> Map.put(header_field, header_val)
        serve(accept_sock, conn)
      :req_end ->
        # responseを返却
        send_resp(accept_sock, conn)
    end
  end

  def read_req(accept_sock) do
    {:ok, raw_msg} = :gen_tcp.recv(accept_sock, 0)
    req_msg = String.trim(raw_msg) # 末尾の改行コードを削除
    # Logger.info "read_req: #{req_msg}"

    case String.split(req_msg, " ") do
      # リクエストラインの解析
      [method, target, prot_ver] ->
        # Logger.info "method:#{method}, target:#{target}, prot_ver:#{prot_ver}"
        {:req_line, method, target, prot_ver}
      # ヘッダ部の解析
      [header_field, header_val] ->
        # Logger.info "header_field:#{header_field}, header_val:#{header_val}"
        {:header_line, header_field, header_val}
      # ヘッダ部以降(改行とbody部)は対応しない
      _ ->
        :req_end
    end
  end

  def send_resp(accept_sock, conn) do
    resp_msg = build_resp_msg(conn)

    :gen_tcp.send(accept_sock, resp_msg)
    :gen_tcp.close(accept_sock)
  end

  def build_resp_msg(conn) do
    Logger.info "conn: #{inspect conn}"

    msg = inspect(conn)

"""
HTTP/1.1 200 OK
Content-Length: #{String.length(msg)}

#{msg}
"""
  end
end
