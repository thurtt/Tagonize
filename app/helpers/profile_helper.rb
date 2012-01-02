module ProfileHelper
	def gravatar_url( address, opts = {} )
		s = opts[:size] == nil ? '50' : opts[:size]
		r = opts[:rating] == nil ? 'pg' : opts[:rating]
		d = opts[:default] == nil ? 'mm' : opts[:default]
		return "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(address)}?s=#{s}&r=#{r}&d=#{d}"
	end
end
