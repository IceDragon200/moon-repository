module Moon
  class Repository
    module Version
      MAJOR, MINOR, TEENY, PATCH = 1, 1, 0, nil
      STRING = [MAJOR, MINOR, TEENY, PATCH].compact.join('.')
    end
    VERSION = Version::STRING
  end
end
