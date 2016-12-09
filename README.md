# RabbitmqProcedureCall
foo

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rabbitmq_procedure_call'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rabbitmq_procedure_call

## Usage

### Define a procedure

#### Simple class

```ruby
class HelloProcedure < RabbitmqProcedureCall::Procedure
  def perform(params={})
    name = params.fetch('name', 'World')
    hello_msg = "Hello #{name} !"
    respond(msg: hello_msg)
  end
end
HelloProcedure.new(:say_hello).start
```

#### Or use block
```ruby
RabbitmqProcedureCall::Procedure.define(:say_hello) do |procedure|
  name = procedure.params.fetch('name', 'World')
  hello_msg = "Hello #{name} !"

  procedure.respond(msg: hello_msg)
end
```

### Use procedure (caller)

```ruby
say_hello = RabbitmqProcedureCall::Caller.new(:say_hello, timeout = 4)
response = say_hello.call(name: 'Foo')
puts response['msg']
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pagedegeek/rabbitmq_procedure_call.

