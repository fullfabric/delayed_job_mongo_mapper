module Delayed
  module PsychExt
    class ToRuby
      def visit_Psych_Nodes_Mapping(object)
        return revive(Psych.load_tags[object.tag], object) if Psych.load_tags[object.tag]

        case object.tag
        when /^!ruby\/MongoMapper:(.+)$/
          klass = resolve_class($1)
          payload = Hash[*object.children.map { |c| accept c }]
          begin
            klass.find!(payload["attributes"]["_id"])
          rescue MongoMapper::DocumentNotFound
            raise Delayed::DeserializationError
          end
        else
          super(object)
        end
      end
    end
  end
end
