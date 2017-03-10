module MatconClient
    class Slot
    	attr_reader :address, :material_id
        attr_accessor :material

    	def initialize(attrs)
    		@address = attrs.fetch(:address)
    		mat = attrs.fetch(:material, nil)
    		if mat.is_a? String
    			@material_id = mat
    			@material = nil
    		elsif mat.is_a? Hash
    			@material = MatconClient::Material.new(mat)
    			@material_id = @material.id
    		end
    	end

    	def empty?
    		@material_id.nil?
    	end

        def material=(material)
            @material=material
            @material_id=material.id
        end
    end
end