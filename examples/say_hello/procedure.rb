$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require 'rabbitmq_procedure_call'

# first method (with class)
# class HelloProcedure < RabbitmqProcedureCall::Procedure
#   def perform(params={})
#     name = params.fetch('name', 'World')
#     hello_msg = "Hello #{name} !"
#     respond(msg: hello_msg)
#   end
# end
# HelloProcedure.new(:say_hello).start

# or use block
RabbitmqProcedureCall::Procedure.define(:say_hello) do |procedure|
  name = procedure.params.fetch('name', 'World')
  hello_msg = "Hello #{name} !"

  procedure.respond(msg: hello_msg)
end
