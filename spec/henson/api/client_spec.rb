require "spec_helper"

describe Henson::API::Client do
  let(:client) { described_class.new("foo.com") }

  describe "#initialize" do
    it "requires a host" do
      expect(lambda { described_class.new }).to \
        raise_error(ArgumentError)

      expect(described_class.new "foo.test").to \
        be_a(described_class)
    end
  end

  describe "#request" do
  end

  describe "#handle" do
    let(:response) { mock }

    describe "successful response status" do
      it "returns a sane Hash if the response body is empty" do
        response.expects(:success?).returns(true)
        response.expects(:body).returns("").once

        expect(client.handle response).to eq({"ok" => true})
      end

      it "returns the JSON parsed response body if non-empty" do
        env = {:response_headers => {"content-type" => "application/json"}}

        response.expects(:success?).returns(true)
        response.expects(:body).returns(MultiJson.dump({ "foo" => "bar"})).twice
        response.expects(:env).returns(env)

        expect(client.handle response).to eq({"foo" => "bar"})
      end
    end

    describe "redirect response status" do
      describe "301" do
        it "calls request again with the new location" do
          env = {
            :method   => :get,
            :response_headers => { "location" => "http://foo.com/next" }
          }

          response.expects(:success?).returns(false)
          response.expects(:status).returns(301).once
          response.expects(:env).returns(env).twice

          client.expects(:request).with(:get, "http://foo.com/next", {"bar" => "baz"})

          client.handle response, "bar" => "baz"
        end
      end

      describe "302" do
        it "calls request again with the new location" do
          env = {
            :method => :get,
            :response_headers => { "location" => "http://foo.com/next" }
          }

          response.expects(:success?).returns(false)
          response.expects(:status).returns(302).once
          response.expects(:env).returns(env).twice

          client.expects(:request).with(:get, "http://foo.com/next", {"bar" => "baz"})

          client.handle response, "bar" => "baz"
        end
      end
    end

    describe "unsuccessful response status" do
      it "raises an API error" do
        response.expects(:success?).returns(false)
        response.expects(:status).returns("404").twice
        response.expects(:env).returns({:url => "https://foo.com/"})

        expect(lambda { client.handle response, "bar" => "baz" }).to \
          raise_error(Henson::APIError, /API returned 404 for https:\/\/foo.com\/ with \{"bar"=>"baz"\}/)
      end
    end
  end
end
