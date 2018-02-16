'use strict'

const LocationsSQLiteGenerator = require('./LocationsSQLiteGenerator')

const inputFilePath = process.argv[2]
const templateFilePath = process.argv[3]
const outputFilePath = process.argv[4]

const locationsSQLiteGenerator = new LocationsSQLiteGenerator(inputFilePath, templateFilePath, outputFilePath)

locationsSQLiteGenerator.run()
  .then(() => {
    console.log('Done!')
  })
  .catch((error) => {
    console.error('An unexpected error occured!')
    console.error(error)
  })