# frozen_string_literal: true

RSpec.describe Physical::Package do
  subject(:package) { described_class.new(args) }

  context 'with no args given' do
    let(:args) { {} }

    it "has no items" do
      expect(subject.items).to be_empty
    end

    it "is an infitely large box" do
      expect(subject.container).to be_a(Physical::Box)
      expect(subject.dimensions).to eq(
        [Measured::Length.new(BigDecimal::INFINITY, :cm)] * 3
      )
    end
  end

  describe "#items" do
    let(:args) { {} }

    subject { package.items }

    it { is_expected.to be_empty }
  end

  describe "#<<" do
    let(:args) { {} }
    let(:item) { Physical::Item.new(dimensions: [2, 2, 2].map { |d| Measured::Length(d, :cm) }) }

    subject { package.items }

    before do
      package << item
    end

    it { is_expected.to contain_exactly(item) }

    context 'with an item already present' do
      let(:args) { {items: [item]} }

      before do
        package << item
      end

      it { is_expected.to contain_exactly(item) }
    end
  end

  describe "#>>" do
    let(:args) { {items: [item]} }
    let(:item) { Physical::Item.new(dimensions: [2, 2, 2].map { |d| Measured::Length(d, :cm) }) }

    subject { package.items }

    before do
      package >> item
    end

    it { is_expected.to be_empty }
  end

  describe "#weight" do
    let(:args) do
      {
        container: Physical::Box.new(weight: Measured::Weight(0.8, :lb)),
        items: [
          Physical::Item.new(weight: Measured::Weight(0.2, :lb)),
          Physical::Item.new(weight: Measured::Weight(1, :lb))
        ]
      }
    end

    subject { package.weight }

    it "adds the weight of the container with that of the items" do
      expect(subject).to eq(Measured::Weight(2, :lb))
    end

    context 'if no items given' do
      let(:args) do
        {
          container: Physical::Box.new(weight: Measured::Weight(0.8, :lb)),
          items: []
        }
      end

      it "does not blow up" do
        expect(subject).to eq(Measured::Weight(0.8, :lb))
      end
    end
  end

  describe 'dimension methods' do
    let(:args) { { container: Physical::Box.new(dimensions: [1,2,3].map { |d| Measured::Length(d, :cm)}) } }

    it 'forwards them to the container' do
      expect(package.length).to eq(Measured::Length(3, :cm))
      expect(package.width).to eq(Measured::Length(2, :cm))
      expect(package.depth).to eq(Measured::Length(1, :cm))
    end
  end

  describe "#remaining_volume" do
    let(:args) do
      {
        container: Physical::Box.new(dimensions: [1, 2, 3].map { |d| Measured::Length(d, :cm) }),
        items: Physical::Item.new(dimensions: [1, 1, 1].map { |d| Measured::Length(d, :cm) })
      }
    end

    subject { package.remaining_volume }

    it { is_expected.to eq(Measured::Volume(5, :ml)) }
  end

  describe "#id" do
    subject { package.id }

    context "id is given" do
      let(:args) { {id: "12345"} }

      it { is_expected.to eq("12345") }
    end

    context "no ID is given" do
      let(:args) { {} }

      it { is_expected.to be_present }
    end
  end

  describe 'factory' do
    subject { FactoryBot.build(:physical_package) }

    it 'has plausible attributes' do
      expect(subject.weight).to eq(Measured::Weight(1327.37, :g))
    end
  end

  describe '#void_fill_weight' do
    subject { package.void_fill_weight }

    context 'when void fill density is given' do
      let(:container) do
        Physical::Box.new(
          dimensions: [2, 2, 2].map { |d| Measured::Length(d, :cm) },
          inner_dimensions: [1, 1, 1].map { |d| Measured::Length(d, :cm) }
        )
      end

      let(:args) { {container: container, void_fill_density: Measured::Weight.new(7, :mg)} }

      it 'calculates the void fill weight from inner dimensions' do
        is_expected.to be_a(Measured::Weight)
        expect(subject.convert_to(:g).value.to_f).to eq(0.007)
      end
    end
  end
end
