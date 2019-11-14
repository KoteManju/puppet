class Puppet::HTTP::Service::Ca < Puppet::HTTP::Service
  HEADERS = { 'Accept' => 'text/plain' }.freeze

  def get_certificate(name)
    response = @client.get(
      with_base_url("/certificate/#{name}"),
      headers: HEADERS
    )

    return response.body.to_s if response.success?

    raise Puppet::HTTP::ResponseError.new(response)
  end

  def get_certificate_revocation_list(if_modified_since: nil)
    request_headers = if if_modified_since
                        h = HEADERS.dup
                        h['If-Modified-Since'] = if_modified_since.httpdate
                        h
                      else
                        HEADERS
                      end

    response = @client.get(
      with_base_url("/certificate_revocation_list/ca"),
      headers: request_headers
    )

    return response.body.to_s if response.success?

    raise Puppet::HTTP::ResponseError.new(response)
  end

  def put_certificate_request(name, csr)
    response = @client.put(
      with_base_url("/certificate_request/#{name}"),
      headers: HEADERS,
      content_type: 'text/plain',
      body: csr.to_pem
    )

    return response.body.to_s if response.success?

    raise Puppet::HTTP::ResponseError.new(response)
  end
end