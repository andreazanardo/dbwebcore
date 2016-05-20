class ColumnsController < ApplicationController
  # before_action :set_column, only: [:show, :edit, :update, :editor_update, :destroy, :estendi_riga]
  before_action :set_column, except: [:index, :new, :create]

  # GET /columns
  # GET /columns.json
  def index
    @columns = Column.all
  end

  # GET /columns/1
  # GET /columns/1.json
  def show
  end

  # GET /columns/new
  def new
    @column = Column.new
  end

  # GET /columns/1/edit
  def edit
  end

  # POST /columns
  # POST /columns.json
  def create
    @column = Column.new(column_params)

    respond_to do |format|
      if @column.save
        format.html { redirect_to @column, notice: 'column was successfully created.' }
        format.json { render :show, status: :created, location: @column }
      else
        format.html { render :new }
        format.json { render json: @column.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /columns/1
  # PATCH/PUT /columns/1.json
  def update
    respond_to do |format|
      if @column.update(column_params)
        format.html { redirect_to @column, notice: 'column was successfully updated.' }
        format.json { render :show, status: :ok, location: @column }
      else
        format.html { render :edit }
        format.json { render json: @column.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /columns/1/editor_update
  # PATCH/PUT /columns/1/editor_update.json
  def editor_update
    respond_to do |format|
      @column.contenuto = params[:contenuto]
      @column.save
      format.html { head :no_content }
      format.json { render :show, status: :ok, location: @column }
    end
  end

  # DELETE /columns/1
  # DELETE /columns/1.json
  def destroy
    @column.destroy
    respond_to do |format|
      format.html { redirect_to columns_url, notice: 'Column was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def estendi_riga
    @row = @column.row
    @row.estesa = true
    @row.save
    respond_to do |format|
      # format.html { redirect_to columns_url, notice: 'Row was successfully extended.' }
      format.js
      # format.json { head :no_content }
    end
  end

  def riduci_riga
    @row = @column.row
    @row.estesa = false
    @row.save
    respond_to do |format|
      format.js
    end
  end

  def inserisci_riga_prima
    @row = @column.row
    posizione = @row.ordine
    page = @row.page

    # prendo la collezione delle righe e aumento di uno l'ordine di tutte quelle con ordine >= posizione, a partire dall'ultima
    rows = Row.where('ordine >= ? AND page_id = ?', posizione, page.id).order(ordine: :asc)
    rows.each do |riga|
      riga.ordine = riga.ordine + 1
      riga.save
    end

    # creo una riga vuota
    @row2 = Row.create(ordine: posizione, page_id: page.id)
    @row2.save

    # creo due colonne vuote
    column = Column.create(ordine: 1, larghezza: 12, row_id: @row2.id, contenuto: '<p>Cantami o Diva del pelide Achille l\'ira funesta...</p>')
    column.save
  end

  def inserisci_riga_dopo
    @row = @column.row
    posizione = @row.ordine
    page = @row.page

    # prendo la collezione delle righe e aumento di uno l'ordine di tutte quelle con ordine > posizione
    rows = Row.where('ordine > ? AND page_id = ?', posizione, page.id).order(ordine: :asc)
    rows.each do |riga|
      riga.ordine = riga.ordine + 1
      riga.save
    end

    # creo una riga vuota
    @row2 = Row.create(ordine: posizione + 1, page_id: page.id)
    @row2.save

    # creo due colonne vuote
    column = Column.create(ordine: 1, larghezza: 12, row_id: @row2.id, contenuto: '<p>Cantami o Diva del pelide Achille l\'ira funesta...</p>')
    column.save
  end

  def elimina_riga
    @row = @column.row
    @row.destroy
    respond_to do |format|
      format.js
    end
  end

  def inserisci_colonna_prima
    @row = @column.row
    posizione = @column.ordine

    # conto le colonne esistenti
    numero_colonne = Column.where('row_id = ?', @row.id).count

    # procedo solo se sono meno di dodici
    if numero_colonne < 12 then
      # prendo la collezione delle colonne e aumento di uno l'ordine di tutte quelle con ordine >= posizione
      columns = Column.where('ordine >= ? AND row_id = ?', posizione, @row.id).order(ordine: :asc)

      resto = 0
      columns.each do |colonna|
        if colonna.larghezza > 1 then
          resto = resto + 1
          colonna.larghezza = colonna.larghezza - 1
        end

        colonna.ordine = colonna.ordine + 1
        colonna.save
      end
      if resto >= 1 then
        # creo una colonna vuota
        @column2 = Column.create(ordine: posizione, larghezza: resto, row_id: @row.id, contenuto: '<p>Cantami o Diva del pelide Achille l\'ira funesta...</p>')
        @column2.save
      end
    end
  end

  def inserisci_colonna_dopo
    @row = @column.row
    posizione = @column.ordine

    # prendo la collezione delle colonne e aumento di uno l'ordine di tutte quelle con ordine >= posizione, a partire dall'ultima
    columns = Column.where('ordine > ? AND row_id = ?', posizione, @row.id).order(ordine: :asc)
    somma_larghezze = 0
    prima = true
    resto = 0
    columns.each do |colonna|
      somma_larghezze = somma_larghezze + colonna.larghezza
      if prima then
        mezza_larghezza = colonna.larghezza / 2
        resto = colonna.larghezza - mezza_larghezza
        if mezza_larghezza < 1 then
          mezza_larghezza = 1
        end

        colonna.larghezza = mezza_larghezza
      end
      colonna.ordine = colonna.ordine + 1
      colonna.save
      prima = false
    end
    if resto < 1 then
      resto = 1
    end

    # creo una colonna vuota
    @column2 = Column.create(ordine: posizione + 1, larghezza: resto, row_id: @row.id, contenuto: '<p>Cantami o Diva del pelide Achille l\'ira funesta...</p>')
    @column2.save
  end

  def allarga_colonna
    @row = @column.row
    posizione = @column.ordine

    vicina = Column.where('ordine > ? AND row_id = ?', posizione, @row.id).order(ordine: :asc).first

    vicina.larghezza = vicina.larghezza - 1 if vicina.larghezza > 1
    vicina.save

    @column.larghezza = @column.larghezza + 1
    @column.save
  end

  def stringi_colonna
    @row = @column.row
    posizione = @column.ordine

    vicina = Column.where('ordine > ? AND row_id = ?', posizione, @row.id).order(ordine: :asc).first

    if(@column.larghezza > 1) then
      vicina.larghezza = vicina.larghezza + 1
      vicina.save

      @column.larghezza = @column.larghezza - 1
      @column.save
    end
  end

  def elimina_colonna
    @row = @column.row
    @column.destroy
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_column
      @column = Column.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def column_params
      params.require(:column).permit(:ordine, :contenuto, :larghezza, :row_id)
    end
end
