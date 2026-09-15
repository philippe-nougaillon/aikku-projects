module TestHelpers
  def create_account(name = nil)
    name ||= "Account #{SecureRandom.hex(4)}"
    Account.create!(name: name)
  end

  def create_user(account: nil, role: :admin, email: nil, username: nil, name: nil)
    account ||= create_account
    email ||= "user-#{SecureRandom.hex(4)}@example.com"
    username ||= "user_#{SecureRandom.hex(4)}"
    name ||= "Test User"
    User.create!(
      account: account,
      email: email,
      username: username,
      name: name,
      password: "password123",
      password_confirmation: "password123",
      role: role
    )
  end

  def create_project(account: nil, user: nil, name: nil, workflow: 1)
    user ||= create_user(account: account)
    account ||= user.account
    name ||= "Project #{SecureRandom.hex(4)}"
    project = Project.create!(account: account, name: name, workflow: workflow)
    project.participants.create!(user: user)
    project
  end

  def create_todolist(project: nil, name: nil)
    project ||= create_project
    name ||= "Todolist #{SecureRandom.hex(4)}"
    Todolist.create!(project: project, name: name)
  end

  def create_todo(todolist: nil, user: nil, name: nil)
    todolist ||= create_todolist
    user ||= todolist.project.users.first || create_user(account: todolist.project.account)
    name ||= "Todo #{SecureRandom.hex(4)}"
    Todo.create!(todolist: todolist, user: user, name: name)
  end
end

RSpec.configure do |config|
  config.include TestHelpers
end
