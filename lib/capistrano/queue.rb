# task :deploy do
#   run_locally do
#     include ::Capistrano::Queue
#     queue_start!
#     execute "ls /tmp/1"
#     execute "ls /tmp/2"
#     queue_run!
#   end
# end
module Capistrano
  module Queue
    def commands
      Thread.current[:commands] ||= []
    end

    def queue_reset!
      Thread.current[:commands] = []
    end

    def queue_mode
      Thread.current[:queue_mode]
    end

    def queue_mode=(bool)
      Thread.current[:queue_mode] = bool
    end

    def queue_start!
      self.queue_mode = true
      queue_reset!
    end

    def queue_run!
      queue_run.tap { queue_reset! }
    end

    def queue_run
      self.queue_mode = false
      return if commands.nil? or commands.empty?
      command = commands.join("\n")
      execute(command)
    end

    def execute(command)
      if self.queue_mode
        commands << command
      else
        super(command) # original execute
      end
    end
  end
end
