module MatconClient
  class Container < Model
    self.endpoint = 'containers'

    def slots
    	@slots ||= make_slots(super)
    end

    def material_ids
    	slots.lazy.reject(&:empty?).map(&:material_id).force
    end

    def materials
      materials = []
      slots_to_fetch = []
      slots.each do |s|
        if s.material_id && s.material
          materials.append(s.material)
        elsif s.material_id && s.material.nil?
          slots_to_fetch.append(s)
        end
      end

      rs = MatconClient::Material.where(_id: { "$in": slots_to_fetch.map(&:material_id) }).result_set
      slots_to_fetch.each do |s|
        s.material = rs.find{|m| s.material_id == m.id }
      end
      slots.map(&:material).compact
    end

  private
    def make_slots(superslots)
    	superslots.map { |s| MatconClient::Slot.new(s) }
    end
  end
end