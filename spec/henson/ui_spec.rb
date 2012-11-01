require 'spec_helper'

require 'henson/ui'

describe Henson::UI do
  let(:ui) { Henson::UI.new Thor::Shell::Basic.new }

  context "when quiet" do
    before do
      Henson.settings.stubs(:[]).with(:quiet).returns(true)
    end

    context "when verbose" do
      before do
        Henson.settings.stubs(:[]).with(:verbose).returns(true)
      end

      it "debug sends a message" do
        ui.expects(:log).with("noize").once
        ui.debug "noize"
      end

      it "info does not send a message" do
        ui.expects(:log).with("hello").never
        ui.info "hello"
      end

      it "warning sends a message" do
        ui.expects(:log).with("get worried", :yellow).once
        ui.warning "get worried"
      end

      it "error sends a message" do
        ui.expects(:log).with("freak out", :red).once
        ui.error "freak out"
      end
    end

    context "when not verbose" do
      before do
        Henson.settings.stubs(:[]).with(:verbose).returns(false)
      end

      it "debug does not send a message" do
        ui.expects(:log).with("noize").never
        ui.debug "noize"
      end

      it "info does not send a message" do
        ui.expects(:log).with("hello").never
        ui.info "hello"
      end

      it "warning sends a message" do
        ui.expects(:log).with("get worried", :yellow).once
        ui.warning "get worried"
      end

      it "error sends a message" do
        ui.expects(:log).with("freak out", :red).once
        ui.error "freak out"
      end
    end
  end

  context "when not quiet" do
    let(:ui) { Henson::UI.new Thor::Shell::Basic.new }

    before do
      Henson.settings.stubs(:[]).with(:quiet).returns(false)
    end

    context "when verbose" do
      before do
        Henson.settings.stubs(:[]).with(:verbose).returns(true)
      end

      it "debug sends a message" do
        ui.expects(:log).with("noize").once
        ui.debug "noize"
      end

      it "info sends a message" do
        ui.expects(:log).with("hello").once
        ui.info "hello"
      end

      it "warning sends a message" do
        ui.expects(:log).with("get worried", :yellow).once
        ui.warning "get worried"
      end

      it "error sends a message" do
        ui.expects(:log).with("freak out", :red).once
        ui.error "freak out"
      end
    end

    context "when not verbose" do
      before do
        Henson.settings.stubs(:[]).with(:verbose).returns(false)
      end

      it "debug does not send a message" do
        ui.expects(:log).with("noize").never
        ui.debug "noize"
      end

      it "info sends a message" do
        ui.expects(:log).with("hello").once
        ui.info "hello"
      end

      it "warning sends a message" do
        ui.expects(:log).with("get worried", :yellow).once
        ui.warning "get worried"
      end

      it "error sends a message" do
        ui.expects(:log).with("freak out", :red).once
        ui.error "freak out"
      end
    end
  end
end