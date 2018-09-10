module.exports = {
  solc: { 
  	optimizer: { 
  		enabled: true, 
  		runs: 200 
  	} 
  },
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*"
    },
    coverage: {
      host: "localhost",
      port: 8555,
      network_id: "*",
      gasLimit: 0xfffffffffff, 
      gasPrice: 0x01
    },
  },
};
