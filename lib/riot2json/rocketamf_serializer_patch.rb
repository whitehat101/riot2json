# from RocketAMF_pure 1.0.0
# rocketamf/pure/serializer.rb after line 357 add:
#   class_name = obj.type if obj.class == RocketAMF::Values::TypedHash

module RocketAMF
  module Pure
    class Serializer
      private

      def amf3_write_object obj, props=nil, traits=nil
        @stream << AMF3_OBJECT_MARKER

        # Caching...
        if @object_cache[obj] != nil
          amf3_write_reference @object_cache[obj]
          return
        end
        @object_cache.add_obj obj

        # Calculate traits if not given
        is_default = false
        if traits.nil?
          traits = {
                    :class_name => @class_mapper.get_as_class_name(obj),
                    :members => [],
                    :externalizable => false,
                    :dynamic => true
                   }
          is_default = true unless traits[:class_name]
        end
        class_name = is_default ? "__default__" : traits[:class_name]
        class_name = obj.type if obj.class == RocketAMF::Values::TypedHash  # ADDED CODE

        # Write out traits
        if (class_name && @trait_cache[class_name] != nil)
          @stream << pack_integer(@trait_cache[class_name] << 2 | 0x01)
        else
          @trait_cache.add_obj class_name if class_name

          # Write out trait header
          header = 0x03 # Not object ref and not trait ref
          header |= 0x02 << 2 if traits[:dynamic]
          header |= 0x01 << 2 if traits[:externalizable]
          header |= traits[:members].length << 4
          @stream << pack_integer(header)

          # Write out class name
          if class_name == "__default__"
            amf3_write_utf8_vr("")
          else
            amf3_write_utf8_vr(class_name.to_s)
          end

          # Write out members
          traits[:members].each {|m| amf3_write_utf8_vr(m)}
        end

        # If externalizable, take externalized data shortcut
        if traits[:externalizable]
          obj.write_external(self)
          return
        end

        # Extract properties if not given
        props = @class_mapper.props_for_serialization(obj) if props.nil?

        # Write out sealed properties
        traits[:members].each do |m|
          amf3_serialize props[m]
          props.delete(m)
        end

        # Write out dynamic properties
        if traits[:dynamic]
          # Write out dynamic properties
          props.sort.each do |key, val| # Sort props until Ruby 1.9 becomes common
            amf3_write_utf8_vr key.to_s
            amf3_serialize val
          end

          # Write close
          @stream << AMF3_CLOSE_DYNAMIC_OBJECT
        end
      end

    end
  end
end
