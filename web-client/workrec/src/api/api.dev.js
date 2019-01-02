export default class DevAPI {
  static works = []

  static getWorkList() {
    return new Promise((resolve, reject) => {
      resolve({
        works: this.works
      })
    })
  }

  static addWork(title) {
    return new Promise((resolve, reject) => {
      const index = this.works.length + 1
      this.works = this.works.concat({
        id: `${index}`,
        title: title,
        state: 1,
        createdAt: new Date(),
        updatedAt: new Date()
      })
      resolve({})
    })
  }

  static deleteWork(id) {
    return new Promise((resolve, reject) => {
      this.works = this.works.filter(work => work.id !== id)
      resolve({})
    })
  }
}

