require './lib/odf-report'
require 'ostruct'
require 'faker'
require 'launchy'


  class Item
    attr_accessor :name, :sid, :children, :image
    def initialize(_name, _sid, _image, _children=[])
      @name=_name
      @sid=_sid
      @children=_children
      @image=_image
    end
  end


    @items = []
    @items << Item.new("LOST",           '007', 'test/templates/piriapolis.jpg', %w(sawyer juliet hurley locke jack freckles))
    @items << Item.new("ALIAS",          '302', 'test/templates/rails.png', %w(sidney sloane jack michael marshal))
    @items << Item.new("GREY'S ANATOMY", '220', 'test/templates/rails.png', %w(meredith christina izzie alex george))
    @items << Item.new("BREAKING BAD",   '556', 'test/templates/piriapolis.jpg', %w(pollos gus mike heisenberg))


    report = ODFReport::Report.new("test/templates/test_sections.odt") do |r|

      r.add_field("TAG_01", Time.now)
      r.add_field("TAG_02", "TAG-2 -> New tag")

      r.add_section("SECTION_01", @items) do |s|

        s.add_field('NAME') { |i| i.name }

        s.add_field('SID', :sid)

        s.add_table('TABLE_S1', :children, :header=>true) do |t|
          t.add_column('NAME1') { |item| "-> #{item}" }
          t.add_column('INV')   { |item| item.to_s.reverse.upcase }
        end

        s.add_image('GRAPH') { |item| ::File.expand_path(item.image) }
      end

    end

    report.generate("test/result/test_sections.odt")
