# 次に挙げるクラスのいかなるインスタンスからも、hogeメソッドが呼び出せる
# それらのhogeメソッドは、全て"hoge"という文字列を返す
# - String
# - Integer
# - Numeric
# - Class
# - Hash
# - TrueClass

# NOTICE: 本当は、それぞれの Class を open して定義したほうが良い
class Object
  def hoge
    'hoge'
  end
end
