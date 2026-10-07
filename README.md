# Modelo Físico da Base de Dados — Insight Places

Este documento descreve a estrutura física da base de dados relacional da plataforma **Insight Places** em **MySQL**. O projeto foi estruturado para gerir o ecossistema de aluguer de hospedagens, associando proprietários, propriedades, hóspedes, reservas e avaliações com foco em alta disponibilidade e extração de insights estratégicos.

---

## 1. Visão Geral da Arquitetura

A base de dados é constituída por **5 tabelas principais**:

1. **`proprietarios`**: Regista os anfitriões que disponibilizam imóveis/acomodações na plataforma.
2. **`clientes`**: Armazena as informações dos hóspedes que efetuam reservas.
3. **`hospedagens`**: Detalha os imóveis disponíveis, respetiva localização, tipo e tarifário por noite.
4. **`alugueis`**: Regista o histórico e o estado das reservas de alojamento.
5. **`avaliacoes`**: Guarda as pontuações e comentários deixados pelos hóspedes após a estadia.

---

## 2. Estrutura das Tabelas

### 2.1. Tabela `proprietarios`
Armazena a informação dos proprietários/anfitriões dos imóveis.

| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `proprietario_id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Identificador único do proprietário. |
| `nome` | `VARCHAR(100)` | `NOT NULL` | Nome completo ou razão social. |
| `cpf_cnpj` | `VARCHAR(20)` | `NOT NULL`, `UNIQUE` | Documento de identificação fiscal (CPF ou CNPJ). |
| `email` | `VARCHAR(100)` | `NOT NULL`, `UNIQUE` | Endereço de correio eletrónico. |
| `telefone` | `VARCHAR(20)` | Nulo permitido | Número de contacto telefónico. |
| `data_registo` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` | Data e hora em que a conta foi criada. |

---

### 2.2. Tabela `clientes`
Guarda os dados dos hóspedes registados.

| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `cliente_id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Identificador único do cliente. |
| `nome` | `VARCHAR(100)` | `NOT NULL` | Nome completo do cliente. |
| `cpf` | `VARCHAR(11)` | `NOT NULL`, `UNIQUE` | CPF do cliente (11 dígitos). |
| `email` | `VARCHAR(100)` | `NOT NULL`, `UNIQUE` | Correio eletrónico de acesso e contacto. |
| `telefone` | `VARCHAR(20)` | Nulo permitido | Número de telefone do hóspede. |
| `data_nascimento` | `DATE` | `NOT NULL` | Data de nascimento do utilizador. |
| `data_registo` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` | Data e hora do registo na plataforma. |

---

### 2.3. Tabela `hospedagens`
Regista os imóveis e acomodações listados na plataforma.

| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `hospedagem_id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Identificador único da propriedade. |
| `proprietario_id` | `INT` | `FOREIGN KEY` (`proprietarios`) | Referência ao anfitrião responsável pelo imóvel. |
| `nome_propriedade` | `VARCHAR(100)` | `NOT NULL` | Título do anúncio da hospedagem. |
| `tipo_hospedagem` | `ENUM` | `CASA`, `APARTAMENTO`, `QUARTO`, `POUSADA` | Categoria do imóvel. |
| `endereco` | `VARCHAR(255)` | `NOT NULL` | Endereço completo da propriedade. |
| `cidade` | `VARCHAR(50)` | `NOT NULL` | Cidade onde o imóvel está localizado. |
| `estado` | `CHAR(2)` | `NOT NULL` | Sigla da unidade federativa / estado. |
| `preco_noite` | `DECIMAL(10,2)` | `CHECK (preco_noite > 0)` | Valor diário cobrado pela estadia. |
| `ativo` | `BOOLEAN` | `DEFAULT TRUE` | Indica se o imóvel está disponível para reserva. |

---

### 2.4. Tabela `alugueis`
Gere os contratos e reservas de alojamento efetuados.

| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `aluguel_id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Identificador único da reserva. |
| `hospedagem_id` | `INT` | `FOREIGN KEY` (`hospedagens`) | Propriedade reservada. |
| `cliente_id` | `INT` | `FOREIGN KEY` (`clientes`) | Hóspede titular da reserva. |
| `data_checkin` | `DATE` | `NOT NULL` | Data de entrada pretendida. |
| `data_checkout` | `DATE` | `NOT NULL` | Data de saída pretendida. |
| `valor_total` | `DECIMAL(10,2)` | `CHECK (valor_total >= 0)` | Montante total calculado para o período. |
| `status_aluguel` | `ENUM` | `PENDENTE`, `CONFIRMADO`, `CANCELADO`, `CONCLUIDO` | Estado atual do aluguer. |
| `data_reserva` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` | Data e hora de criação da reserva. |

---

### 2.5. Tabela `avaliacoes`
Armazena o feedback dos utilizadores sobre as suas estadias.

| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `avaliacao_id` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Identificador único da avaliação. |
| `aluguel_id` | `INT` | `FOREIGN KEY` (`alugueis`), `UNIQUE` | Reserva avaliada (1 avaliação por aluguer). |
| `nota` | `INT` | `CHECK (nota BETWEEN 1 AND 5)` | Pontuação atribuída de 1 a 5. |
| `comentario` | `TEXT` | Nulo permitido | Opinião textual sobre a estadia. |
| `data_avaliacao` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` | Data e hora em que a avaliação foi enviada. |

---

## 3. Relacionamentos do Modelo

* **`proprietarios` (1) ── (N) `hospedagens`**: Um proprietário pode gerir várias propriedades na plataforma.
* **`clientes` (1) ── (N) `alugueis`**: Um hóspede pode efetuar vários alugueres ao longo do tempo.
* **`hospedagens` (1) ── (N) `alugueis`**: Cada acomodação pode ter múltiplos alugueres em datas distintas.
* **`alugueis` (1) ── (1) `avaliacoes`**: Cada aluguer concluído pode originar no máximo uma avaliação.

---

## 4. Otimização e Índices

Para assegurar resposta rápida em consultas analíticas e na pesquisa de disponibilidade de alojamentos, foram aplicados os seguintes índices:

* **`idx_hospedagens_cidade_estado`**: Otimiza a procura de imóveis por cidade e estado nos filtros da plataforma.
* **`idx_alugueis_datas`**: Acelera a verificação de sobreposição de datas (`check-in` e `check-out`) ao realizar novas reservas.
* **`idx_alugueis_status`**: Facilita a filtragem de reservas ativas, concluídas ou canceladas para relatórios financeiros.
* **`idx_alugueis_cliente`**: Otimiza a consulta do histórico de estadias por cliente.

---

## 5. Como Executar o Script no MySQL Workbench / CLI

1. Abra o **MySQL Workbench** ou aceda via terminal CLI.
2. Ligue-se à sua instância do servidor MySQL (versão 8.0 ou superior).
3. Abra um novo separador de consulta (`SQL Query`) e cole o código SQL do projeto.
4. Execute o script na totalidade para criar a base de dados `insight_places`, as tabelas, os índices, popular os dados iniciais e visualizar o relatório analítico de exemplo.
