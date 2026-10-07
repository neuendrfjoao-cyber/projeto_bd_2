-- ============================================================
-- PROJETO INSIGHT PLACES: MODELO FÍSICO DO BANCO DE DADOS (MySQL)
-- ============================================================

CREATE DATABASE IF NOT EXISTS insight_places;
USE insight_places;

-- 1. CRIAÇÃO DAS TABELAS (DDL)

CREATE TABLE proprietarios (
    proprietario_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf_cnpj VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    data_registo DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    data_nascimento DATE NOT NULL,
    data_registo DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE hospedagens (
    hospedagem_id INT AUTO_INCREMENT PRIMARY KEY,
    proprietario_id INT NOT NULL,
    nome_propriedade VARCHAR(100) NOT NULL,
    tipo_hospedagem ENUM('CASA', 'APARTAMENTO', 'QUARTO', 'POUSADA') NOT NULL,
    endereco VARCHAR(255) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado CHAR(2) NOT NULL,
    preco_noite DECIMAL(10, 2) NOT NULL CHECK (preco_noite > 0),
    ativo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_hospedagens_proprietario FOREIGN KEY (proprietario_id) REFERENCES proprietarios(proprietario_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE alugueis (
    aluguel_id INT AUTO_INCREMENT PRIMARY KEY,
    hospedagem_id INT NOT NULL,
    cliente_id INT NOT NULL,
    data_checkin DATE NOT NULL,
    data_checkout DATE NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL CHECK (valor_total >= 0),
    status_aluguel ENUM('PENDENTE', 'CONFIRMADO', 'CANCELADO', 'CONCLUIDO') DEFAULT 'PENDENTE',
    data_reserva DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_alugueis_hospedagem FOREIGN KEY (hospedagem_id) REFERENCES hospedagens(hospedagem_id) ON DELETE RESTRICT,
    CONSTRAINT fk_alugueis_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE avaliacoes (
    avaliacao_id INT AUTO_INCREMENT PRIMARY KEY,
    aluguel_id INT NOT NULL UNIQUE,
    nota INT NOT NULL CHECK (nota BETWEEN 1 AND 5),
    comentario TEXT,
    data_avaliacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_avaliacoes_aluguel FOREIGN KEY (aluguel_id) REFERENCES alugueis(aluguel_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. CRIAÇÃO DE ÍNDICES PARA OTIMIZAÇÃO DE DESEMPENHO E CONSULTAS ANALÍTICAS

CREATE INDEX idx_hospedagens_
