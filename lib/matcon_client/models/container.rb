module MatconClient
  class Container < Model
    self.endpoint = 'containers'

    def slots
    	@slots ||= make_slots(super)
    end

    def material_ids
    	slots.lazy.reject(&:empty?).map(&:material_id).force
    end

  private
    def make_slots(superslots)
    	superslots.map { |s| MatconClient::Slot.new(s) }
    end
  end
end