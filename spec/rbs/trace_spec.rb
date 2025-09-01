# frozen_string_literal: true

RSpec.describe RBS::Trace do
  let(:trace) { described_class.new(log_level: :debug, raises: true) }

  # @rbs (RBS::Trace, ?Symbol) -> String
  def to_rbs(trace, comment_format = nil)
    trace.files.each_value.map { |file| file.with_rbs(comment_format) }.join
  end

  describe "#enable" do
    it "supports instance methods without arguments" do
      source = <<~RUBY
        class A
          def m
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A.new.m }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs () -> nil
            def m
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs () -> nil
            def m
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: () -> nil
            def m
            end
          end
        RUBY
      end
    end

    it "supports instance methods with req arguments" do
      source = <<~RUBY
        class A
          def m(x)
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A.new.m(1) }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (Integer) -> nil
            def m(x)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (Integer) -> nil
            def m(x)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (Integer) -> nil
            def m(x)
            end
          end
        RUBY
      end
    end

    it "supports instance methods with opt arguments" do
      source = <<~RUBY
        class A
          def m(x = 1)
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A.new.m }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (?Integer) -> nil
            def m(x = 1)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (?Integer) -> nil
            def m(x = 1)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (?Integer) -> nil
            def m(x = 1)
            end
          end
        RUBY
      end
    end

    it "supports instance methods with rest arguments" do
      source = <<~RUBY
        class A
          def m(*x)
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A.new.m(1, 2) }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (*Integer) -> nil
            def m(*x)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (*Integer) -> nil
            def m(*x)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (*Integer) -> nil
            def m(*x)
            end
          end
        RUBY
      end
    end

    it "supports instance methods with keyreq arguments" do
      source = <<~RUBY
        class A
          def m(x:)
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A.new.m(x: 1) }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (x: Integer) -> nil
            def m(x:)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (x: Integer) -> nil
            def m(x:)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (x: Integer) -> nil
            def m(x:)
            end
          end
        RUBY
      end
    end

    it "supports instance methods with key arguments" do
      source = <<~RUBY
        class A
          def m(x: 0)
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A.new.m }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (?x: Integer) -> nil
            def m(x: 0)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (?x: Integer) -> nil
            def m(x: 0)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (?x: Integer) -> nil
            def m(x: 0)
            end
          end
        RUBY
      end
    end

    it "supports instance methods with keyrest arguments" do
      source = <<~RUBY
        class A
          def m(**opts)
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A.new.m(x: 1, y: 2) }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (**Integer) -> nil
            def m(**opts)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (**Integer) -> nil
            def m(**opts)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (**Integer) -> nil
            def m(**opts)
            end
          end
        RUBY
      end
    end

    it "supports instance methods with raise" do
      source = <<~RUBY
        class A
          def m
            raise "error"
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable do
          mod::A.new.m
        rescue StandardError
          nil
        end

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs () -> nil
            def m
              raise "error"
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs () -> nil
            def m
              raise "error"
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: () -> nil
            def m
              raise "error"
            end
          end
        RUBY
      end
    end

    it "supports methods that call methods that raise exceptions" do
      source = <<~RUBY
        class A
          def m(x)
            foo
          end

          def foo
            raise "error"
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable do
          mod::A.new.m(1)
        rescue StandardError
          nil
        end

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (Integer) -> nil
            def m(x)
              foo
            end

            # @rbs () -> nil
            def foo
              raise "error"
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (Integer) -> nil
            def m(x)
              foo
            end

            # @rbs () -> nil
            def foo
              raise "error"
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (Integer) -> nil
            def m(x)
              foo
            end

            #: () -> nil
            def foo
              raise "error"
            end
          end
        RUBY
      end
    end

    it "supports singleton methods" do
      source = <<~RUBY
        class A
          def self.m
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A.m }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs () -> nil
            def self.m
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs () -> nil
            def self.m
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: () -> nil
            def self.m
            end
          end
        RUBY
      end
    end

    it "supports Union type arguments" do
      source = <<~RUBY
        class A
          def m(x)
          end
        end
      RUBY

      load_source(source) do |mod|
        trace.enable do
          obj = mod::A.new
          obj.m(1)
          obj.m("a")
        end

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (Integer | String) -> nil
            def m(x)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (Integer | String) -> nil
            def m(x)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (Integer | String) -> nil
            def m(x)
            end
          end
        RUBY
      end
    end

    it "supports Union type return value" do
      source = <<~RUBY
        class A
          def m(is_int)
            is_int ? 1 : "a"
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable do
          obj = mod::A.new
          result_int = obj.m(true) # rubocop:disable Lint/UselessAssignment
          result_str = obj.m(false) # rubocop:disable Lint/UselessAssignment
        end

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (bool) -> (Integer | String)
            def m(is_int)
              is_int ? 1 : "a"
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (bool) -> (Integer | String)
            def m(is_int)
              is_int ? 1 : "a"
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (bool) -> (Integer | String)
            def m(is_int)
              is_int ? 1 : "a"
            end
          end
        RUBY
      end
    end

    it "supports Optional type arguments" do
      source = <<~RUBY
        class A
          def m(x)
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable do
          obj = mod::A.new
          obj.m(1)
          obj.m(nil)
        end

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (Integer?) -> nil
            def m(x)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (Integer?) -> nil
            def m(x)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (Integer?) -> nil
            def m(x)
            end
          end
        RUBY
      end
    end

    it "if the argument is nil, the RBS argument will also be nil" do
      source = <<~RUBY
        class A
          def m(x)
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A.new.m(nil) }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (nil) -> nil
            def m(x)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (nil) -> nil
            def m(x)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (nil) -> nil
            def m(x)
            end
          end
        RUBY
      end
    end

    it "ignores a method generated by class_eval" do
      source = <<~RUBY
        class A
          class_eval('def m; 1; end')
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A.new.m }

        expect(trace.files).to be_empty
      end
    end

    it "supports anonymous arguments" do
      source = <<~RUBY
        class A
          def m(*, **, &)
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A.new.m }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs (*untyped, **untyped) -> nil
            def m(*, **, &)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs (*untyped, **untyped) -> nil
            def m(*, **, &)
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: (*untyped, **untyped) -> nil
            def m(*, **, &)
            end
          end
        RUBY
      end
    end

    context "when not specified additional generics size" do
      it "supports generics with Array, Hash and Range" do
        source = <<~RUBY
          class A
            def m(x, y, z)
            end
          end
        RUBY
        load_source(source) do |mod|
          trace.enable { mod::A.new.m([], {}, 0..10) }

          expect(to_rbs(trace)).to eq(<<~RUBY)
            class A
              # @rbs (Array[untyped], Hash[untyped, untyped], Range[untyped]) -> nil
              def m(x, y, z)
              end
            end
          RUBY

          expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
            class A
              # @rbs (Array[untyped], Hash[untyped, untyped], Range[untyped]) -> nil
              def m(x, y, z)
              end
            end
          RUBY

          expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
            class A
              #: (Array[untyped], Hash[untyped, untyped], Range[untyped]) -> nil
              def m(x, y, z)
              end
            end
          RUBY
        end
      end
    end

    context "when specified additional generics size" do
      it "supports generics with specified classes" do
        source = <<~RUBY
          class A
            def m(a, b, c, d)
            end
          end
        RUBY
        load_source(source) do |mod|
          trace.add_generics_size!("CSV::Table" => 1)
          trace.enable do
            require "csv"
            mod::A.new.m([], {}, 0..10, CSV::Table.new([]))
          end

          expect(to_rbs(trace)).to eq(<<~RUBY)
            class A
              # @rbs (Array[untyped], Hash[untyped, untyped], Range[untyped], CSV::Table[untyped]) -> nil
              def m(a, b, c, d)
              end
            end
          RUBY

          expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
            class A
              # @rbs (Array[untyped], Hash[untyped, untyped], Range[untyped], CSV::Table[untyped]) -> nil
              def m(a, b, c, d)
              end
            end
          RUBY

          expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
            class A
              #: (Array[untyped], Hash[untyped, untyped], Range[untyped], CSV::Table[untyped]) -> nil
              def m(a, b, c, d)
              end
            end
          RUBY
        end
      end
    end

    it "supports subclasses of BasicObject" do
      source = <<~RUBY
        class A < BasicObject
          def m(x)
            A.new
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable do
          obj = mod::A.new.m(mod::A.new) # rubocop:disable Lint/UselessAssignment
        end

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A < BasicObject
            # @rbs (#{mod}::A) -> #{mod}::A
            def m(x)
              A.new
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A < BasicObject
            # @rbs (#{mod}::A) -> #{mod}::A
            def m(x)
              A.new
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A < BasicObject
            #: (#{mod}::A) -> #{mod}::A
            def m(x)
              A.new
            end
          end
        RUBY
      end
    end

    it "supports eval, but the return value is always void" do
      source = <<~RUBY
        class A
          def m
          end
        end
      RUBY
      load_source(source) do |mod| # rubocop:disable Lint/UnusedBlockArgument
        trace.enable do
          obj = eval("mod::A.new.m") # rubocop:disable Lint/UselessAssignment, Style/EvalWithLocation
        end

        expect(to_rbs(trace)).to eq(<<~RUBY)
          class A
            # @rbs () -> void
            def m
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          class A
            # @rbs () -> void
            def m
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          class A
            #: () -> void
            def m
            end
          end
        RUBY
      end
    end

    it "supports multiple nested modules in a single file" do # rubocop:disable RSpec/ExampleLength
      # also defining `class B::C` to check sanity of the stack operations
      source = <<~RUBY
        module A
          module B
          end

          class B::C
            def m = 'a'
          end

          class D
            def n = 1
          end
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A::D.new.n }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          module A
            module B
            end

            class B::C
              def m = 'a'
            end

            class D
              # @rbs () -> Integer
              def n = 1
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          module A
            module B
            end

            class B::C
              def m = 'a'
            end

            class D
              # @rbs () -> Integer
              def n = 1
            end
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          module A
            module B
            end

            class B::C
              def m = 'a'
            end

            class D
              #: () -> Integer
              def n = 1
            end
          end
        RUBY
      end
    end

    it "inline signatures will be written for methods in nested modules defined w/ ::" do
      source = <<~RUBY
        module A
          module B
          end
        end

        class A::B::C
          def m = 1
        end
      RUBY
      load_source(source) do |mod|
        trace.enable { mod::A::B::C.new.m }

        expect(to_rbs(trace)).to eq(<<~RUBY)
          module A
            module B
            end
          end

          class A::B::C
            # @rbs () -> Integer
            def m = 1
          end
        RUBY

        expect(to_rbs(trace, :rbs_keyword)).to eq(<<~RUBY)
          module A
            module B
            end
          end

          class A::B::C
            # @rbs () -> Integer
            def m = 1
          end
        RUBY

        expect(to_rbs(trace, :rbs_colon)).to eq(<<~RUBY)
          module A
            module B
            end
          end

          class A::B::C
            #: () -> Integer
            def m = 1
          end
        RUBY
      end
    end
  end
end
