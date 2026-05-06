class AdminPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def stats?
    user && ['pierre-emmanuel.dacquet@aikku.eu', 'philippe.nougaillon@aikku.eu',
             'sebastien.pourchaire@aikku.eu'].include?(user.email)
  end

  def suppression_compte?
    stats?
  end

  def mentions_legales?
    true
  end
end
