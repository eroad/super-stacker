module Fn
end

def Ref(logicalName)
  { "Ref" => logicalName }
end

# TODO: Decide if we'll keep this. Currently undocumented.
def Tag(key, value)
  {"Key" => key, "Value" => value}
end
